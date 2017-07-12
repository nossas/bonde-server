module ControllerHelper
  def render_404
    skip_authorization

    render nothing: true, status: 404
  end

  def render_status status, messages
    skip_authorization

    render json: messages, status: status
  end
end