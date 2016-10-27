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
end
