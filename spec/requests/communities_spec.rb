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

  describe 'POST /invitation' do
    context 'valid invitation' do 
      let!(:invitation) { create :invitation, expires: (Date.today + 1) }
      let(:returned) { JSON.parse(response.body) }

      before do
        post "/invitation", {format: :json, code: invitation.code, email: invitation.email}
      end

      it { expect(response).to have_http_status(200) }

      it do
        expect(returned['id']).to eq(CommunityUser.last.id)
      end

      it do
        expect(returned['user_id']).to eq(CommunityUser.last.user_id)
      end

      it do
        expect(returned['community_id']).to eq(CommunityUser.last.community_id)
      end

      it do
        expect(returned['role']).to eq(CommunityUser.last.role)
      end

    end

    context 'expired invitation' do
      let(:invitation) {create :invitation, expired: true}
      let(:returned) { JSON.parse(response.body) }

      before do
        post "/invitation", {format: :json, code: invitation.code, email: invitation.email}
      end

      it { expect(response).to have_http_status(412) }
    end

    context 'expired invitation' do
      let!(:invitation) {create :invitation, expired: false, expires: (Date.today - 1)}
      let(:returned) { JSON.parse(response.body) }

      before do
        post "/invitation", {format: :json, code: invitation.code, email: invitation.email}
      end

      it { expect(response).to have_http_status(412) }
    end

    context 'inexistent invitation' do
      before do
        post "/invitation", {format: :json, code: '1234', email: 'ask@me.com'}
      end

      it { expect(response).to have_http_status(404) }
    end
  end
end
