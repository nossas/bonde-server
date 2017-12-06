class ApplicationController < ActionController::API

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from PagarMe::PagarMeError, with: :pagarme_error
  rescue_from Mailchimpable::MailchimpableException, with: :mailchimpable_exception

  after_action :verify_authorized, unless: -> {devise_controller?}
  after_action :verify_policy_scoped, unless: -> {devise_controller?}

  helper_method :devise_controller? # just for keeping legacy for a moment

  def devise_controller?
    false
  end

  def current_user
    auth_service = AuthenticationService.new(request)
    auth_service.current_user
  end

  protected

  def user_not_authorized
    render json: {errors: [ ( I18n.t 'return.status.unauthorized', default: 'Unauthorized') ]}, status: :unauthorized
  end

  private

  def pagarme_error(error)
    Raven.capture_exception(error) unless Rails.env.test?
    render json: { errors: error.to_json }, status: :internal_server_error
  end

  def mailchimpable_exception(exception)
    unless exception.message =~ /.*title="Member Exists".*/
      Raven.capture_message("Erro ao gravar usuário na lista:\nEmail: #{email}\nMergeVars: #{merge_vars.to_json unless merge_vars.nil?}\nOptions: #{options.to_json}\n#{exception}") unless Rails.env.test?
      logger.error("List signature error:\nParams: (email: '#{email}', merge_vars: '#{merge_vars}', options: '#{options}')\nError:#{exception}")
    end
  end

  def get_error status
    if  [500, 503].include? status
      I18n.t "http.client.error.status_#{status}"
    end
  end
end
