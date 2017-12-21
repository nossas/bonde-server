class RootController < ActionController::API
  respond_to :json

  def index
    database_connected = ActiveRecord::Base.connected?
    database_config = ActiveRecord::Base.configurations["default"]
    if database_connected
      result = {
        "status": 200,
        "database_connected": database_connected,
        "default_config": database_config
      }
    else
      result = {
        "status": 404,
        "database_connected": nil,
        "default_config": nil
      }
    end
    render json: result
  end
end
