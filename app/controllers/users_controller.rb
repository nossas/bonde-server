require 'base64'

class UsersController < ApplicationController
  respond_to :json

  after_action :verify_authorized, except: %i[index action_opportunities]
  after_action :verify_policy_scoped, only: %i[index action_opportunities]

  def create
    skip_authorization

    create_user
    if @user.save
      put_token_on_header
      render json: @user
    else
      render json: { errors: @user.errors}, status=>500
    end
  end

  def update
    @user = User.find params[:id]
    authorize @user
    @user.update!(user_params)
    render json: @user
  end

  def user_params
    if params[:user]
      params.require(:user).permit(*policy(@user || User.new).permitted_attributes)
    else
      {}
    end
  end

  def retrieve
    skip_authorization

    status = :not_found
    user = User.find_by_email(params['user']['email'])
    if user
      pass = Base64.encode64(DateTime.now.strftime('%Q').to_s).strip.gsub(/=/, '')
      user.update_attributes password: pass
      user.reload

      Notification.notify! user, :bonde_password_retrieve, {
        new_password: pass,
        user: user
      }
      status = :ok
    end
    render nothing: true, status: status
  end

  private

  def put_token_on_header
    response.header['access-token'] = AuthenticationService.gen_token(@user)
  end

  def create_user
    @user = User.new(params.require(:user).permit(:email, :first_name, :last_name, :password, :avatar))
    @user.admin = true   # @see Invitation.create_community_user
    @user.uid = @user.email
    @user.provider = 'email'
  end
end
