require 'rails_helper'

RSpec.describe DnsRecord, type: :model do
  before do
    allow_any_instance_of(DnsService).to receive(:create_hosted_zone).and_return({
      'delegation_set' => { 'name_servers' => ["ns-1258.awsdns-29.org", "ns-826.awsdns-39.net", "ns-55.awsdns-06.com", "ns-1552.awsdns-02.co.uk"] },
      'hosted_zone' => {'id' => '12312312'}
    })

    allow_any_instance_of(DnsService).to receive(:change_resource_record_sets)
    allow_any_instance_of(DnsService).to receive(:list_resource_record_sets).and_return([])
    allow_any_instance_of(DnsService).to receive(:list_hosted_zones).and_return([])
  end

  subject { build :dns_record }

  it { should belong_to :dns_hosted_zone }
  it { should have_one :community }
  it { should have_many :users }
  
  it { should validate_presence_of :dns_hosted_zone_id }
  it { should validate_presence_of :name }
  it { should validate_length_of(:name).is_at_most(254) }
  it { should validate_presence_of :record_type }
  it { should validate_presence_of :value }
  it { should validate_presence_of :ttl }

  it 'should verify if it\'s name is part of hosted_zone' do
    subject.name = 'notpartof.mydomain.com'

    expect(subject.validate).not_to be
    expect(subject.errors['name'].size).to be 1
  end

  it 'should verify if it name\'s legnth is less than 64 chars ' do
    subject.name = "1234567890123456789012345678901234567890123456789012345678901234.#{subject.dns_hosted_zone.domain_name}"

    expect(subject.validate).not_to be
    expect(subject.errors['name'].size).to be 1
  end

  it 'should accept masks' do
    subject.name = "*.#{subject.dns_hosted_zone.domain_name}"

    expect(subject.validate).to be
  end
end
