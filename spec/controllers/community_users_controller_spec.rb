require 'rails_helper'

RSpec.describe CommunityUsersController, type: :controller do
  let(:user) {User.make!}
  
  before { stub_current_user(user) }

  describe 'GET #index' do
    context 'valid call' do
      let(:community) {Community.make!}

      before do
        @user_role = CommunityUser.make! community: community, user: user
        3.times {CommunityUser.make! community: community}

        get :index, {community_id: community.id}
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return users/roles from community' do
        expect(response.body).to include(JSON.generate({
          user: {
            user_id: @user_role.user.id ,
            first_name: @user_role.user.first_name,
            last_name: @user_role.user.last_name,
            email: @user_role.user.email
          }, 
          role: @user_role.role_str
        }))
        expect(JSON.parse(response.body).count).to be 4
      end
    end

    context 'unauthorized call' do
      let(:community) {Community.make!}

      before do
        3.times {CommunityUser.make! community: community}

        get :index, {community_id: community.id}
      end

      it 'should return a 401 status' do
        expect(response.status).to be 401
      end
    end

    context 'inexistent community' do
      before do
        get :index, {community_id: 0}
      end

      it 'should return a 404 status' do
        expect(response.status).to be 404
      end
    end
  end
end
