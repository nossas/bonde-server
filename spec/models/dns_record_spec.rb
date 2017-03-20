require 'rails_helper'

RSpec.describe DnsRecord, type: :model do
  before do
    allow_any_instance_of(DnsService).to receive(:create_hosted_zone).and_return({
      'delegation_set' => { 'name_servers' => ["ns-1258.awsdns-29.org", "ns-826.awsdns-39.net", "ns-55.awsdns-06.com", "ns-1552.awsdns-02.co.uk"] },
      'hosted_zone' => {'id' => '12312312'}
    })
    allow_any_instance_of(DnsService).to receive(:change_resource_record_sets)
  end

  subject { build :dns_record }

  it { should belong_to :dns_hosted_zone }
  it { should have_one :community }
  it { should have_many :users }
  
  it { should validate_presence_of :dns_hosted_zone_id }
  it { should validate_presence_of :name }
  it { should validate_presence_of :record_type }
  it { should validate_presence_of :value }
  it { should validate_presence_of :ttl }
end
