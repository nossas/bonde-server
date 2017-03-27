class CommunitiesController < ApplicationController
  respond_to :json

  include Pundit
  include PagarmeHelper
  
  before_action :load_community, only: [:list_mobilizations]

  after_action :verify_authorized, except: [:index, :list_mobilizations]
  after_action :verify_policy_scoped, only: [:index, :list_mobilizations]

  def index
    skip_authorization
    skip_policy_scope

    if current_user
      render json: current_user.communities
    else
      render nothing:true, status: :unauthorized
    end
  end


  def create
    @community = Community.new(community_params)
    authorize @community
    if not @community.validate
      render json: @community.errors, :status => 400
    else
      Community.transaction do 
        @community.save!
        create_role
        render json: @community, serializer: CommunitySerializer
      end
    end
  end


  def update
    community = Community.find_by({id: params[:id]})
    if not community
      return404
    else
      begin
        Community.transaction do
          authorize community
          if (recipient_data = params[:community][:recipient])
            recipients community, recipient_data 
          end
          community.update!(community_params)
        end
        render json: community
      rescue ArgumentError => e
        render json:{argument_error: e.message}, status: 400
      end
    end
  end


  def show
    community = Community.find_by({id: params[:id]})
    if community
      authorize community
      render json: community
    else
      return404
    end
  end

  def list_activists
    community = Community.find params[:community_id]

    authorize community

    respond_with do |format|
      format.json do
        render json: community.agg_activists
      end
      format.csv do
        send_data community.agg_activists.copy_to_string, type: Mime::CSV, disposition: "attachment; filename=activists_#{community.name.parameterize}.csv"
      end
    end
  end

  def list_mobilizations
    if ! current_user
      (render_status :unauthorized) and return
    elsif @community
      begin
        @mobilizations = @community.mobilizations.order('updated_at DESC')
        @mobilizations = @mobilizations.where(custom_domain: params[:custom_domain]) if params[:custom_domain].present?
        @mobilizations = @mobilizations.where(slug: params[:slug]) if params[:slug].present?
        @mobilizations = @mobilizations.where(id: params[:ids]) if params[:ids].present?
        render json: policy_scope(@mobilizations)
      rescue StandardError => e
        Raven.capture_exception(e) unless Rails.env.test?
        Rails.logger.error e
      end
    else
      return404
    end    
  end

  def accept_invitation
    skip_authorization
    invitation = Invitation.find_by_email_and_code params['email'], params['code']
    if invitation
      begin
        render json: invitation.create_community_user, serializer: CommunityUserSerializer::CommunityUserSimpleSerializer
      rescue InvitationException
        render nothing: true, status: 412
      end
    else
      render nothing: true, status: :not_found
    end
  end

  private 

  def load_community
    @community = current_user.communities.find_by({id: params['community_id']}) if current_user
  end

  def recipients community, recipient_dt
    recipient_data = to_pagarme_recipient recipient_dt
    validate_recipient recipient_data
    if community.recipient && community.recipient.pagarme_recipient_id && community.recipient.recipient['bank_account']['document_number'] == recipient_dt['bank_account']['document_number']
      recipient = (TransferService.update_recipient community.recipient.pagarme_recipient_id, recipient_data)
      community.recipient.recipient = recipient.to_json
      community.recipient.pagarme_recipient_id = recipient.id
      community.recipient.transfer_day = recipient.transfer_day
      community.recipient.transfer_enabled = recipient.transfer_enabled
      community.recipient.save!
    else
      recipient = (TransferService.register_recipient recipient_data)
      community.recipient = Recipient.create community: community, recipient: recipient.to_json, pagarme_recipient_id: recipient.id, transfer_day: recipient.transfer_day,
          transfer_enabled: recipient.transfer_enabled
    end
    community.save
  end

  def validate_recipient recipient_data
    bank_account = recipient_data['bank_account']
    errors = []
    errors << "Código bancário inválido. Deve ter extamente 3 dígitos." if (bank_account['bank_code'] =~ /^\d{3}$/).nil?
    errors << "Código de agência inválido. Deve ter até 5 dígitos." if (bank_account['agencia'] =~ /^\d{1,5}$/).nil?
    errors << "Dígito verificador da agência inválido. Deve ter apenas um dígito." if (bank_account['agencia_dv'])&&((bank_account['agencia_dv'] =~ /^[\d\w]$/).nil?)
    errors << "Número da conta bancária inválida. Deve ter até 13 dígitos." if (bank_account['conta'] =~ /^\d{1,13}$/).nil?
    errors << "Dígito verificador da conta bancária inválido. Deve ter até 2 caracteres alfanuméricos." if (bank_account['conta_dv'] =~ /^[A-Z0-9]{1,2}$/).nil?
    errors << "Tipo de conta inválido. Deve ter até 2 caracteres alfanuméricos." if (bank_account['type'] =~ /^(conta_corrente)|(conta_poupanca)|(conta_corrente_conjunta)|(conta_poupanca_conjunta)$/).nil?
    errors << "Número de documento inválido. Deve ter 11 ou 14 dígitos" if (bank_account['document_number'] =~ /^\d{11}(\d{3})?$/).nil?
    if errors.count > 0
      raise ArgumentError.new errors 
    end
  end

  def community_params
    if params[:community]
      params.require(:community).permit(*policy(@community || Community.new).permitted_attributes)
    else
      {}
    end
  end

  def create_role
    community_user = CommunityUser.new
    community_user.community = @community
    community_user.user = current_user
    community_user.role = 1
    community_user.save!
  end

  def render_status status
    skip_authorization
    skip_policy_scope
    render :status =>status, :nothing => true
  end

  def return404 
    skip_authorization
    skip_policy_scope
    render :status =>404, :nothing => true
  end
end
