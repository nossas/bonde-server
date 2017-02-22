require 'rails_helper'

RSpec.describe "DnsHostedZones", type: :request do
  let!(:community) { create(:community) }
  let(:user) { create(:user) }
  
  describe "GET /communities/:community_id/dns_hosted_zones" do
    before {
      stub_current_user(user)
    }
    it "works! (now write some real specs)" do
      get community_dns_hosted_zones_path(community_id: community.id)
      expect(response).to have_http_status(200)
    end
  end
end
