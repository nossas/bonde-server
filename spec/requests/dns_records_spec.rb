require 'rails_helper'

RSpec.describe "DnsRecords", type: :request do
  let!(:dns_record) { create(:dns_record) }

  describe "GET /communities/:community_id/dns_hosted_zones/:dns_hosted_zone_id/dns_records" do
    it "works! (now write some real specs)" do
      get community_dns_hosted_zone_dns_records_path community_id: dns_record.community.id, 
        dns_hosted_zone_id: dns_record.dns_hosted_zone.id
      expect(response).to have_http_status(200)
    end
  end
end
