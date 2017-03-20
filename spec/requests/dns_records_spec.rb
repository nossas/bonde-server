require 'rails_helper'

RSpec.describe "DnsRecords", type: :request do
  before do
    allow_any_instance_of(DnsService).to receive(:create_hosted_zone).and_return({
      'delegation_set' => { 'name_servers' => ["ns-1258.awsdns-29.org", "ns-826.awsdns-39.net", "ns-55.awsdns-06.com", "ns-1552.awsdns-02.co.uk"] },
      'hosted_zone' => {'id' => '12312312'}
    })

    allow_any_instance_of(DnsService).to receive(:change_resource_record_sets)
  end
  let!(:dns_record) { create(:dns_record) }

  describe "GET /communities/:community_id/dns_hosted_zones/:dns_hosted_zone_id/dns_records" do
    it "works!" do
      get community_dns_hosted_zone_dns_records_path community_id: dns_record.community.id, 
        dns_hosted_zone_id: dns_record.dns_hosted_zone.id
      expect(response).to have_http_status(200)
    end
  end
end
