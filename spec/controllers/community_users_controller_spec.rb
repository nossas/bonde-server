require 'rails_helper'

RSpec.describe CommunityUsersController, type: :controller do
  let(:user) {User.make!}
  let(:community) {Community.make!}
  
  before { stub_current_user(user) }

  describe 'GET #index' do
    context 'valid call' do

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


  describe 'POST #create' do
    context 'role: owner -> valid call' do
      let(:adding_user) { User.make! }
      before do
        CommunityUser.create! community_id: community.id , user: user, role: 1
        post :create, {
          community_id: community.id,
          format: :json,
          communityUser: {
            user_id: adding_user.id,
            role: 2
          }
        }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return the saved data' do
        expect(response.body).to include "\"user_id\":#{adding_user.id}"
        expect(response.body).to include '"role":2'
      end
    end

    context 'admin valid call' do
      let(:adding_user) { User.make! }
      before do
        CommunityUser.create! community_id: community.id , user: user, role: 2
        post :create, {
          community_id: community.id,
          format: :json,
          communityUser: {
            user_id: adding_user.id,
            role: 3
          }
        }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return the saved data' do
        expect(response.body).to include "\"user_id\":#{adding_user.id}"
        expect(response.body).to include '"role":3'
      end
    end

    it 'should not let simple users to add participants' do
      adding_user = User.make!
      CommunityUser.create! community_id: community.id , user: user, role: 3

      post :create, {
        community_id: community.id,
        format: :json,
        communityUser: {
          user_id: adding_user.id,
          role: 3
        }
      }
      expect(response.status).to be 401
    end

    it 'should not let unknown users to add participants' do
      adding_user = User.make!

      post :create, {
        community_id: community.id,
        format: :json,
        communityUser: {
          user_id: adding_user.id,
          role: 3
        }
      }
      expect(response.status).to be 401
    end

    context 'error messages' do
      context 'missing fields' do
        context '- user' do
          let(:adding_user) { User.make! }
          before do
            CommunityUser.create! community_id: community.id , user: user, role: 2
            post :create, {
              community_id: community.id,
              format: :json,
              communityUser: {
                role: 3
              }
            }
          end

          it 'should return a 400 status' do
            expect(response.status).to be 400
          end

          it 'should return the saved data' do
            expect(response.body).to include "user"
          end
        end

        context '- role' do
          let(:adding_user) { User.make! }
          before do
            CommunityUser.create! community_id: community.id , user: user, role: 2
            post :create, {
              community_id: community.id,
              format: :json,
              communityUser: {
                user_id: adding_user.id
              }
            }
          end

          it 'should return a 400 status' do
            expect(response.status).to be 400
          end

          it 'should return the saved data' do
            expect(response.body).to include "role"
          end
        end
  
      end
      
      context 'invalid values' do
        let(:adding_user) { User.make! }
        before do
          CommunityUser.create! community_id: community.id , user: user, role: 2
          post :create, {
            community_id: community.id,
            format: :json,
            communityUser: {
              user_id: adding_user.id,
              role: 50
            }
          }
        end

        it 'should return a 400 status' do
          expect(response.status).to be 400
        end

        it 'should return the saved data' do
          expect(response.body).to include "role"
        end
      end
    end
  end


  describe 'PUT :update' do
    let(:communityUser) {CommunityUser.create! community: community, user: user, role:2}
    
    context 'valid call' do
      before do
        put :update, {
          community_id: community.id,
          id: communityUser.id,
          communityUser: { role: 3 }
        }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return the saved data' do
        expect(response.body).to include('"role":3')
        expect(response.body).to include("\"user_id\":#{user.id}")
      end
    end

    context 'nonexistent record' do
      before do
        put :update, {
          community_id: community.id,
          id: 0,
          communityUser: { role: 3 }
        }
      end

      it 'should return a 404 status' do
        expect(response.status).to be 404
      end
    end
    
    context 'nonexistent record' do
      before do
        stub_current_user User.make!
        put :update, {
          community_id: community.id,
          id: communityUser.id,
          communityUser: { role: 3 }
        }
      end

      it 'should return a 401 status' do
        expect(response.status).to be 401
      end
    end
    
    context 'invalid role' do
      before do
        put :update, {
          community_id: community.id,
          id: communityUser.id,
          communityUser: { role: 300 }
        }
      end

      it 'should return a 400 status' do
        expect(response.status).to be 400
      end

      it 'should return a 400 status' do
        expect(response.body).not_to eq('[]')
      end
    end
  end



  describe 'DELETE :delete' do
   
    context 'valid call' do
      let(:communityUser) {CommunityUser.create! community: community, user: user, role:2}
      before do
        delete :destroy, {
          community_id: community.id,
          id: communityUser.id
        }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should delete the record' do
        expect(CommunityUser.find_by({id:communityUser.id})).not_to be
      end
    end
    
    context 'user without rights' do
      let(:communityUser) {CommunityUser.create! community: community, user: User.make!, role:3}
      before do
        delete :destroy, {
          community_id: community.id,
          id: communityUser.id
        }
      end

      it 'should return a 401 status' do
        expect(response.status).to be 401
      end

      it 'should not delete the record' do
        expect(CommunityUser.find_by({id:communityUser.id})).to be
      end
    end
    
    context 'nonexistent record' do
      let(:communityUser) {CommunityUser.create! community: community, user: User.make!, role:3}
      before do
        delete :destroy, {
          community_id: community.id,
          id: 0
        }
      end

      it 'should return a 404 status' do
        expect(response.status).to be 404
      end
    end
  end



  describe 'GET #show' do
   
    context 'valid call' do
      let(:communityUser) {CommunityUser.create! community: community, user: user, role:2}
      before do
        get :show, {
          community_id: community.id,
          id: communityUser.id
        }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return the record' do
        expect(response.body).to include("\"id\":#{communityUser.id}")
        expect(response.body).to include("\"user_id\":#{communityUser.user_id}")
        expect(response.body).to include("\"role\":#{communityUser.role}")
      end
    end
    
    context 'user without rights' do
      let(:communityUser) {CommunityUser.create! community: community, user: User.make!, role:3}
      before do
        get :show, {
          community_id: community.id,
          id: communityUser.id
        }
      end

      it 'should return a 401 status' do
        expect(response.status).to be 401
      end

      it 'should not delete the record' do
        expect(CommunityUser.find_by({id:communityUser.id})).to be
      end
    end
    
    context 'nonexistent record' do
      let(:communityUser) {CommunityUser.create! community: community, user: User.make!, role:3}
      before do
        get :show, {
          community_id: community.id,
          id: 0
        }
      end

      it 'should return a 404 status' do
        expect(response.status).to be 404
      end
    end
  end
end
