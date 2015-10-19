require 'platform-api'

module Herokuable
  def create_domain(custom_domain)
    begin
      api_client.domain.create(ENV["CLIENT_APP_NAME"], custom_domain)
    rescue Exception => e
      logger.error(e.message)
    end
  end

  def delete_domain(old_domain)
    begin
      api_client.domain.delete(ENV["CLIENT_APP_NAME"], old_domain)
    rescue Exception => e
      logger.error(e.message)
    end
  end

  def api_client
    return PlatformAPI.connect_oauth(ENV['CLIENT_OAUTH_TOKEN'])
  end
end
