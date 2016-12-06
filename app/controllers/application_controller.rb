class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, unless: -> {devise_controller?}
  after_action :verify_policy_scoped, unless: -> {devise_controller?}

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:first_name, :last_name) }

  end

  def user_not_authorized
    render json: {error: 'Unauthorized'}, status: :unauthorized
  end
end
