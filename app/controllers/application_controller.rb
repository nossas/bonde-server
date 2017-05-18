class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from PagarMe::PagarMeError, with: :pagarme_error
  rescue_from Mailchimpable::MailchimpableException, with: :mailchimpable_exception

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
    Raven.capture_exception(error) unless Rails.env.test?
    match = error.message.match(/^(\d{3})\s(.*)$/)
    error_messages = nil

    if match
      error_messages = [get_error(match[1].to_i)]
    elsif error.try(:errors)
      error_messages = error.errors.map{|e| e.message}
    elsif error.try(:error)
      error_messages = error.error.message
    else
      error_messages = error.message
    end

    render json: { errors: [ "Pagarme: #{error_messages} #{ENV['PAGARME_API_KEY']}" ] }, status: :internal_server_error
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
