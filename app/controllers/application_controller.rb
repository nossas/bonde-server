class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from PagarMe::PagarMeError, with: :pagarme_error

  after_action :verify_authorized, unless: -> {devise_controller?}
  after_action :verify_policy_scoped, unless: -> {devise_controller?}

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:first_name, :last_name) }
  end

  def user_not_authorized
    render json: {errors: [ ( I18n.t 'return.status.unauthorized', default: 'Unauthorized') ]}, status: :unauthorized
  end

  private

  def pagarme_error(error)
    Raven.capture_exception(error)
    match = error.message.match(/^(\d{3})\s(.*)$/)
    message = nil
    if match
      message = get_error match[1].to_i
    elsif error.response
      message = error.response
    else
      message = error.message
    end

    render json: { errors: [ ( error.try(:errors) || error.error ) ] }, status: :internal_server_error
  end

  def get_error status
    if  [500, 503].include? status
      I18n.t "http.client.error.status_#{status}"
    end
  end
end
