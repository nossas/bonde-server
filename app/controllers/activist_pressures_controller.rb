class ActivistPressuresController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[create]
  after_action :verify_policy_scoped, only: %i[]

  def create
    @activist = Activist.new(activist_params.merge(:name => activist_name))
    @activist.save!

    @activist_pressure = ActivistPressure.new(activist_pressure_params.merge(:activist_id => @activist.id))
    @activist_pressure.firstname = firstname
    @activist_pressure.lastname = lastname
    @activist_pressure.pressure = pressure
    @activist_pressure.save!
    render json: @activist_pressure
  end

  private
  def activist_name
    "#{firstname} #{lastname}"
  end

  def activist_params
    if params[:activist_pressure][:activist]
      params[:activist_pressure]
        .require(:activist)
        .permit(*policy(@activist || Activist.new).permitted_attributes)
    end
  end

  def activist_pressure_params
    if params[:activist_pressure]
      params
        .require(:activist_pressure)
        .permit(*policy(@activist_pressure || ActivistPressure.new).permitted_attributes)
    end
  end

  def firstname
    params[:activist_pressure][:activist][:firstname]
  end

  def lastname
    params[:activist_pressure][:activist][:lastname]
  end

  def pressure
    params[:activist_pressure][:pressure]
  end
end
