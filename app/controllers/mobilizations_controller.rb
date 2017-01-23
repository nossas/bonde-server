class MobilizationsController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[index published]
  after_action :verify_policy_scoped, only: %i[index published]

  def index
    # TODO: Lets use has_scope here :)
    begin
      @mobilizations = policy_scope(Mobilization).order('updated_at DESC')
      @mobilizations = @mobilizations.where(user_id: params[:user_id]) if params[:user_id].present?
      @mobilizations = @mobilizations.where(custom_domain: params[:custom_domain]) if params[:custom_domain].present?
      @mobilizations = @mobilizations.where(slug: params[:slug]) if params[:slug].present?
      @mobilizations = @mobilizations.where(id: params[:ids]) if params[:ids].present?
      render json: @mobilizations
    rescue StandardError => e
      Raven.capture_exception(e) unless Rails.env.test?
      Rails.logger.error e
    end
  end

  def published
    begin
      @mobilizations = policy_scope(Mobilization).
        where.not(custom_domain: nil).
        where.not(custom_domain: 'null')
      render json: @mobilizations
    rescue StandardError => e
      Raven.capture_exception(e) unless Rails.env.test?
      Rails.logger.error e
    end

  end

  def create
    @mobilization = Mobilization.new(mobilization_params)
    @mobilization.user = current_user
    authorize @mobilization
    @mobilization.save!
    render json: @mobilization
  end

  def update
    @mobilization = Mobilization.find_by({id: params[:id]})
    if not @mobilization
      return404
    elsif params[:template_mobilization_id]
      template = TemplateMobilization.find_by({id: params[:template_mobilization_id]})
      if template
        authorize @mobilization
        @mobilization.copy_from template
        Mobilization.transaction do 
          @mobilization.save

          template.template_blocks.order(:id).each do |template_block|
            block = Block.create_from template_block, @mobilization
            block.save!
            template_block.template_widgets.order(:id).each do |template_widget|
              widget = Widget.create_from template_widget, block
              widget.save!
            end
          end
          template.uses_number = (template.uses_number || 0 ) + 1
          template.save!
        end
        render json: @mobilization
      else
        return404
      end
    else
      authorize @mobilization
      @mobilization.update!(mobilization_params)
      render json: @mobilization
    end
  end

  def mobilization_params
    if params[:mobilization]
      params.require(:mobilization).permit(*policy(@mobilization || Mobilization.new).permitted_attributes)
    else
      {}
    end
  end

  private 

  def return404
    skip_authorization
    render :status =>404, :nothing => true
  end
end
