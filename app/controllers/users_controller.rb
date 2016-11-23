class UsersController < ApplicationController
  respond_to :json

  after_action :verify_authorized, except: %i[index action_opportunities]
  after_action :verify_policy_scoped, only: %i[index action_opportunities]
  after_action :update_auth_header, only: [:new]

  def create
    skip_authorization

    @user = User.new(params.require(:user).permit(:email, :first_name, :last_name, :password))
    @user.uid = @user.email
    @user.provider = 'email'
    @user.skip_confirmation!
    if @user.save
      sign_in @user
      tok = @user.create_new_auth_token
      tok.keys.each do |field|
        response.header[field] = tok[field]
      end
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
end
