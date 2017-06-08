require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'POST #create' do
    context 'valid creation call' do
      before do
        @data_on_db = User.count
        post :create, { user: {  email: 'my_pesonal@email.com', first_name: 'Paulo', last_name: 'Freire', password: 'learning', avatar: 'http://www.myurl.com/super-ultra-avatar.gif'}, format: 'JSON'  }
      end

      it 'should return 200 on status' do
        expect(response.status).to be 200
      end

      it 'should create a new instance' do
        expect(User.count).to be(@data_on_db + 1)
      end

      context 'should return the correct' do
        before do
          @returned = JSON.parse(response.body)
        end

        it 'email' do
          expect(@returned['email']).to eq 'my_pesonal@email.com'
        end
        it 'first_name' do
          expect(@returned['first_name']).to eq 'Paulo'
        end
        it 'last_name' do
          expect(@returned['last_name']).to eq 'Freire'
        end

        it 'avatar_url' do
          expect(@returned['avatar_url']).to eq 'http://www.myurl.com/super-ultra-avatar.gif'
        end

        it 'should be an admin' do
          expect((User.find @returned['id']).admin).to be true
        end
      end

      it 'should return the sign_in information' do
        expect(response.headers['access-token']).to be
      end

      it 'should create a new instance' do
        expect(User.count). to be(@data_on_db + 1)
      end
    end
  end

  describe 'PUT/PATCH #update' do
    context 'valid call' do
      before do
        @user = User.make!
        stub_current_user(@user)
        patch :update,  {format: 'json', id: @user.id, user: {first_name: 'Hobin', last_name: 'Hood', avatar: 'http://www.myurl.com/super-ultra-avatar.gif'}}
      end

      it 'should return a 200' do
        expect(response.status).to be 200
      end

      context 'field changes' do
        before do
          @recuperado = JSON.parse response.body
        end

        it 'first_name' do
          expect(@recuperado['first_name']).to eq 'Hobin'
        end

        it 'should change last_name' do
          expect(@recuperado['last_name']).to eq 'Hood'
        end

        it 'avatar_url' do
          expect(@recuperado['avatar_url']).to eq 'http://www.myurl.com/super-ultra-avatar.gif'
        end
      end
    end

    context 'diferent user call' do
      before do
        @user = User.make!
        @user2 = User.make!
        stub_current_user(@user2)

        patch :update,  {format: 'json', id: @user.id, user: {first_name: 'Hobin', last_name: 'Hood'}}
      end

      it 'should return a 401 - not authorized' do
        expect(response.status).to be 401
      end
    end

    context 'admin user call' do
      before do
        @user = User.make!
        @user2 = User.make!
        @user2.admin = true
        stub_current_user(@user2)

        patch :update,  {format: 'json', id: @user.id, user: {first_name: 'Hobin', last_name: 'Hood'}}
      end

      it 'should return a 200' do
        expect(response.status).to be 200
      end
    end
  end

  describe '#retrieve' do
    let!(:templ) { create :notification_template, label: :bonde_test_template }
    let!(:user) { create :user, password: '123456789' }

    it do
      Notification.should_receive(:notify!).once

      post :retrieve, { format: :json, user: { email: user.email } }
    end
  end
end
