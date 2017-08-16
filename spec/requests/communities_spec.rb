require 'rails_helper'

RSpec.describe "Communities", type: :request do
  let(:user) { create :user }

  describe "GET /communities" do
    context 'unlogged user' do 
      before { get communities_path }
      
      it { expect(response).to have_http_status(401) }
    end

    context 'logged user' do 
      before do
        stub_current_user(user)
        get communities_path
      end

      it { expect(response).to have_http_status(200) }
    end
  end

  describe 'POST /communities/:community_id/invitation' do
    let(:valid_invitation) { { email: 'ask@me.com', role: 1 } }

    context 'valid invitation' do 
      let!(:user) { create :user }
      let!(:community) { create :community }
      let(:returned) { JSON.parse(response.body) }
      
      before do
        CommunityUser.create user: user, community: community, role: 1
        stub_current_user user

        post "/communities/#{community.id}/invitation", { format: :json, invitation: valid_invitation }
      end

      it { expect(response).to have_http_status(200) }
      
      it do
        expect(returned['email']).to eq('ask@me.com')
      end
      
      it do
        expect(returned['role']).to eq(1)
      end
    end

    context 'inexistent community' do 
      let!(:user) { create :user }
      let(:returned) { JSON.parse(response.body) }
      
      before do
        post "/communities/0/invitation", { format: :json, invitation: valid_invitation }
      end

      it { expect(response).to have_http_status(404) }

    end

    context 'user not member' do 
      let!(:user) { create :user }
      let!(:community) { create :community }
      
      before do
        stub_current_user user

        post "/communities/#{community.id}/invitation", { format: :json, invitation: valid_invitation }
      end

      it { expect(response).to have_http_status(401) }

    end
  end

  describe 'GET /invitation' do
    context 'valid invitation' do 
      let!(:invitation) { create :invitation, expires: (Date.today + 1) }
      let!(:user) { create(:user, email: invitation.email)}

      before do
        get "/invitation", {code: invitation.code, email: invitation.email}
      end

      it { expect(response).to have_http_status(302) }
      it 'should create community user' do
        expect(CommunityUser.where(user_id: user.id).count).to eq(1)
      end
    end

    context 'expired invitation' do
      let(:invitation) {create :invitation, expired: true}
      let!(:user) { create(:user, email: invitation.email)}

      before do
        get "/invitation", {code: invitation.code, email: invitation.email}
      end

      it { expect(response).to have_http_status(302) }
      it 'should not create community user' do
        expect(CommunityUser.where(user_id: user.id).count).to eq(0)
      end
    end

    context 'expired invitation with time' do
      let!(:user) { create(:user, email: invitation.email)}
      let!(:invitation) {create :invitation, expired: false, expires: (Date.today - 1)}

      before do
        get "/invitation", {code: invitation.code, email: invitation.email}
      end

      it { expect(response).to have_http_status(302) }
      it 'should not create community user' do
        expect(CommunityUser.where(user_id: user.id).count).to eq(0)
      end
    end

    context 'inexistent invitation' do
      let!(:user) { create(:user, email: 'ask@me.com')}
      before do
        get "/invitation", {code: '1234', email: 'ask@me.com'}
      end

      it { expect(response).to have_http_status(302) }
      it 'should not create community user' do
        expect(CommunityUser.where(user_id: user.id).count).to eq(0)
      end
    end
  end
end
