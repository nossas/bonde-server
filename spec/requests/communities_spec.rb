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
end