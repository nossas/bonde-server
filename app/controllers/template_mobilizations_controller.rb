class TemplateMobilizationsController < ApplicationController
  respond_to :json

  after_action :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
  	template_mobilizations = policy_scope(TemplateMobilization)
	if params[:global] == 'true'
		template_mobilizations = template_mobilizations.where('global=true')
	else
		template_mobilizations = template_mobilizations.where("user_id = #{current_user.id}")
	end
	render json:template_mobilizations
  end

  def destroy
	template_mobilization = TemplateMobilization.find_by({id: params[:id]})
	if template_mobilization
	  authorize template_mobilization
	  template_mobilization.transaction do 
	    template_mobilization.template_blocks.each do |block|
	      block.template_widgets.each do |widget|
	        widget.delete
	      end
	      block.delete
	    end
	   	template_mobilization.delete
	  end
	else
	  skip_authorization
	  render :status=>404, :nothing => true
	end
  end

  def create
  	mobilization = Mobilization.find params[:mobilization_id]
  	if mobilization
  		template_mobilization = TemplateMobilization.create_from mobilization
  		template_mobilization.global = params[:global] || false
  		template_mobilization.save
  	end
  end
end
