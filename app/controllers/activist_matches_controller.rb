class ActivistMatchesController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[create]
  after_action :verify_policy_scoped, only: %i[]

  def create
    @activist = Activist.new(activist_params.merge(:name => activist_name))
    @activist.save!

    @activist_match = ActivistMatch.new(activist_match_params.merge(:activist_id => @activist.id))
    @activist_match.firstname = params[:activist_match][:activist][:firstname]
    @activist_match.lastname = params[:activist_match][:activist][:lastname]
    @activist_match.save!
    render json: @activist_match
  end

  def activist_name
    "#{params[:activist_match][:activist][:firstname]} #{params[:activist_match][:activist][:lastname]}"
  end

  def activist_params
    if params[:activist_match][:activist]
      params[:activist_match].require(:activist).permit(*policy(@activist || Activist.new).permitted_attributes)
    else
    end
  end

  def activist_match_params
    if params[:activist_match]
      params.require(:activist_match).permit(*policy(@activist_match || ActivistMatch.new).permitted_attributes)
    else
    end
  end
end
