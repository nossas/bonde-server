class Widgets::FillController < ApplicationController
  respond_to :json
  after_action :verify_authorized, except: %i[create]
  after_action :verify_policy_scoped, only: %i[]

  def create
    @widget = Widget.find(params[:widget_id])
    @activist = Activist.new(activist_params)
    @activist.save!

    result = {}
    if @widget.kind === 'pressure'
      @activist_pressure = ActivistPressure.new(activist_pressure_params)
      @activist_pressure.firstname = firstname
      @activist_pressure.lastname = lastname
      @activist_pressure.mail = mail
      @activist_pressure.save!
      result = @activist_pressure
    end

    render json: result
  end

  private
  def activist_name
    "#{firstname} #{lastname}"
  end

  def activist_params
    if params[:fill][:activist]
      params[:fill].require(:activist)
        .permit(*policy(@activist || Activist.new).permitted_attributes)
        .merge(:name => activist_name)
    end
  end

  def activist_pressure_params
    if params[:fill]
      params.require(:fill)
        .permit(*policy(@activist_pressure || ActivistPressure.new).permitted_attributes)
        .merge(:activist_id => @activist.id, :widget_id => params[:widget_id])
    end
  end

  def firstname
    params[:fill][:activist][:firstname]
  end

  def lastname
    params[:fill][:activist][:lastname]
  end

  def mail
    params[:fill][:mail]
  end
end
