class AuthenticationService
  def self.gen_token(user)
    JWT.encode({
      user_id: user.id
    }, ENV['JWT_SECRET'], 'HS256')
  end

  def initialize(request)
    @request = request
  end

  def token
    @request.headers['access-token']
  end

  def has_token?
    token.present?
  end

  def valid_token?
    return unless has_token?
    begin
      @decoded_token, @signature = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: 'HS256' })
      @decoded_token.present?
    rescue
      false
    end
  end

  def current_user
    return unless valid_token?
    User.find(@decoded_token['user_id'])
  end
end
