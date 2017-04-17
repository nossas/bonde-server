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

  describe 'GET /communities/:community_id/dns_hosted_zones/:dns_hosted_zones_id/check' do
    [true, false].each do |checked|
      context "returning #{checked}" do
        let(:dns_hosted_zone) {create :dns_hosted_zone}
        let(:returned_dns_hosted_zone) { JSON.parse(response) }

        before do
          allow_any_instance_of(DnsHostedZone).to receive(:check_ns_correctly_filled!).and_return(checked)
          allow_any_instance_of(DnsService).to receive(:create_hosted_zone)
          allow_any_instance_of(DnsService).to receive(:list_hosted_zones).and_return([])
          allow_any_instance_of(DnsService).to receive(:change_resource_record_sets)

          get  "/communities/#{dns_hosted_zone.community.id}/dns_hosted_zones/#{dns_hosted_zone.id}/check"
        end  

        it do
          expect(response).to have_http_status(200)
        end
      end
    end
  end

end
