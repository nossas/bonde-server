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
		if not (params[:goal] and params[:name] and params[:mobilization_id])
			skip_authorization
			render :status=>400, json: { missing_fields: list_missing_fields() }
		else
			create_from_mobilization params[:mobilization_id]
		end
	end

	private

	def list_missing_fields 
		missing = []
		missing << :mobilization_id if not params[:mobilization_id]
		missing << :goal if not params[:goal] 
		missing << :name if not params[:name] 
		missing
	end

	def create_from_mobilization mob_id
		mobilization = Mobilization.find_by({id: mob_id})
		if mobilization
			authorize mobilization
			template_mobilization = template_creation(mobilization)
			render json: template_mobilization
		else
			skip_authorization
			render :status=>404, :nothing => true
		end		
	end

	def template_creation mobilization
		template_mobilization = TemplateMobilization.create_from(mobilization)
		template_mobilization.global = params[:global] || false
		template_mobilization.user = current_user
		template_mobilization.name = params[:name]
		template_mobilization.goal = params[:goal]
		TemplateMobilization.transaction do
			template_mobilization.save!

			mobilization.blocks.each do |block|
				template_block = TemplateBlock.create_from block, template_mobilization
				template_mobilization.save!

				block.widgets.each do |widget|
					template_widget = TemplateWidget.create_from widget, template_block
					template_widget.save!
				end
			end
		end	
		template_mobilization
	end
end
