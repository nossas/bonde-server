class ActivistMatchesController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[create]
  after_action :verify_policy_scoped, only: %i[]

  def create
    @activist = find_or_create_activist

    @activist_match = ActivistMatch.new(activist_match_params.merge(:activist_id => @activist.id))
    @activist_match.firstname = params[:activist_match][:activist][:firstname]
    @activist_match.lastname = params[:activist_match][:activist][:lastname]
    @activist_match.save!
    render json: @activist_match
  end

  def activist_name
    "#{params[:activist_match][:activist][:firstname]} #{params[:activist_match][:activist][:lastname]}".presence || activist_params[:name]
  end

  def find_or_create_activist
    if activist = Activist.where(email: activist_params[:email]).order(id: :asc).first
      activist
    else
      Activist.create!(activist_params.merge(:name => activist_name))
    end
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
