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

  private

  def put_token_on_header
    response.header['access-token'] = AuthenticationService.gen_token(@user)
  end

  def create_user
    @user = User.new(params.require(:user).permit(:email, :first_name, :last_name, :password, :avatar))
    @user.admin = true
    @user.uid = @user.email
    @user.provider = 'email'
  end
end
