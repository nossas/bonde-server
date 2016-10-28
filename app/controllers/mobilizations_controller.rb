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
    rescue Exception => e
      Rails.logger.error e
    end
  end

  def published
    begin
      @mobilizations = policy_scope(Mobilization).
        where.not(custom_domain: nil).
        where.not(custom_domain: 'null')
      render json: @mobilizations
    rescue Exception => e
      Rails.logger.error e
    end

  end

  def create
    if params[:template_mobilization_id]
      template = TemplateMobilization.find_by({id: params[:template_mobilization_id]})
      if template
        mobilization = Mobilization.create_from template
        mobilization.user = current_user
        authorize mobilization
        Mobilization.transaction do 
          mobilization.save!

          template.template_blocks.each do |template_block|
            block = Block.create_from template_block, mobilization
            block.save!
            template_block.template_widgets.each do |template_widget|
              widget = Widget.create_from template_widget, block
              widget.save!
            end
          end
        end
        render json: mobilization
      else
        skip_authorization
        render :status =>404, :nothing => true
      end
    else
      @mobilization = Mobilization.new(mobilization_params)
      @mobilization.user = current_user
      authorize @mobilization
      @mobilization.save!
      render json: @mobilization
    end
  end

  def update
    @mobilization = Mobilization.find(params[:id])
    authorize @mobilization
    @mobilization.update!(mobilization_params)
    render json: @mobilization
  end

  def mobilization_params
    if params[:mobilization]
      params.require(:mobilization).permit(*policy(@mobilization || Mobilization.new).permitted_attributes)
    else
      {}
    end
  end
end
