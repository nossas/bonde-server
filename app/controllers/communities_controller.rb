class CommunitiesController < ApplicationController
  respond_to :json

  include Pundit
  include PagarmeHelper
  
  after_action :verify_authorized, except: [:index, :list_mobilizations]
  after_action :verify_policy_scoped, only: [:index, :list_mobilizations]

  def index
    skip_authorization
    skip_policy_scope

    render json: current_user.communities
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
        authorize community
        if (recipient_data = params[:community][:recipient])
          recipients community, recipient_data 
        end
        community.update!(community_params)
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
    skip_authorization
    skip_policy_scope

    community = Community.find params[:community_id]

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
    community = Community.find_by({id: params['community_id']})

    if community
      begin
        @mobilizations = policy_scope(community.mobilizations).order('updated_at DESC')
        @mobilizations = @mobilizations.where(custom_domain: params[:custom_domain]) if params[:custom_domain].present?
        @mobilizations = @mobilizations.where(slug: params[:slug]) if params[:slug].present?
        @mobilizations = @mobilizations.where(id: params[:ids]) if params[:ids].present?
        render json: @mobilizations
      rescue StandardError => e
        Raven.capture_exception(e) unless Rails.env.test?
        Rails.logger.error e
      end
    else
      return404
    end    
  end

  private 

  def recipients community, recipient_dt
    recipient_data = to_pagarme_recipient recipient_dt
    validate_recipient recipient_data
    recipient = nil
    if community.pagarme_recipient_id && community.recipient['bank_account']['document_number'] == recipient_dt['bank_account']['document_number']
      recipient = (TransferService.update_recipient community.pagarme_recipient_id, recipient_data)
    else
      TransferService.remove_recipient community.pagarme_recipient_id if community.pagarme_recipient_id
      recipient = (TransferService.register_recipient recipient_data)
    end
    community.recipient = recipient.to_json
    community.pagarme_recipient_id = recipient.id
    community.transfer_day = recipient.transfer_day
    community.transfer_enabled = recipient.transfer_enabled
    community.save
  end

  def validate_recipient recipient_data
    bank_account = recipient_data['bank_account']
    errors = []
    errors << "Código bancário inválido. Deve ter extamente 3 dígitos." if (bank_account['bank_code'] =~ /^\d{3}$/).nil?
    errors << "Código de agência inválido. Deve ter até 5 dígitos." if (bank_account['agencia'] =~ /^\d{1,5}$/).nil?
    errors << "Dígito verificador da agência inválido. Deve ter apenas um dígito." if (bank_account['agencia_dv'] =~ /^\d$/).nil?
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

  def return404
    skip_authorization
    skip_policy_scope
    render :status =>404, :nothing => true
  end
end
