require 'rails_helper'

RSpec.describe "FormEntries", type: :request do
  # before do
  #   allow_any_instance_of(DnsService).to receive(:create_hosted_zone).and_return({
  #     'delegation_set' => { 'name_servers' => ["ns-1258.awsdns-29.org", "ns-826.awsdns-39.net", "ns-55.awsdns-06.com", "ns-1552.awsdns-02.co.uk"] },
  #     'hosted_zone' => {'id' => '12312312'}
  #   })

  #   allow_any_instance_of(DnsService).to receive(:change_resource_record_sets)
  # end
  # let!(:dns_record) { create(:dns_record) }

  # describe "GET /communities/:community_id/dns_hosted_zones/:dns_hosted_zone_id/dns_records" do
  #   it "works!" do
  #     get community_dns_hosted_zone_dns_records_path community_id: dns_record.community.id, 
  #       dns_hosted_zone_id: dns_record.dns_hosted_zone.id
  #     expect(response).to have_http_status(200)
  #   end
  # end
  let(:user) { create(:user) }

  before { stub_current_user(user) }

  describe 'GET /mobilizations/:mobilization_id/form_entries' do
    let!(:widget) { create :widget }

    let!(:form_entry_1) { create :form_entry, widget: widget }
    let!(:form_entry_2) { create :form_entry }

    context 'format csv joint_fields' do
      before { get "/mobilizations/#{widget.mobilization.id}/form_entries.csv?widget_id=#{widget.id}&INFO=disjoint_fields" }

      it { expect(response).to have_http_status(200) }

      it do
        expect(response.body).to include('email')
        expect(response.body).to include('first name')
        expect(response.body).to include('last name')
        expect(response.body).not_to include('fields')
      end
    end

    context 'format csv' do
      before { get "/mobilizations/#{widget.mobilization.id}/form_entries.csv?widget_id=#{widget.id}" }

      it { expect(response).to have_http_status(200) }

      it do
        expect(response.body).to include('fields')
      end
    end
  end
end
