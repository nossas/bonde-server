require 'rails_helper'

RSpec.describe DnsRecordPolicy do
  before do
    allow_any_instance_of(DnsService).to receive(:create_hosted_zone).and_return({
      'delegation_set' => { 'name_servers' => ["ns-1258.awsdns-29.org", "ns-826.awsdns-39.net", "ns-55.awsdns-06.com", "ns-1552.awsdns-02.co.uk"] },
      'hosted_zone' => {'id' => '12312312'}
    })
    allow_any_instance_of(DnsService).to receive(:change_resource_record_sets)
  end

  let!(:user) { create :user }
  let(:user_admin) { create :user, admin: true }

  describe "for a Visitor" do
    let(:used_user) { nil }

    subject { described_class.new used_user, DnsRecord.new}
    
    it { should_not allows(:index) }
    it { should_not allows(:show) }
    it { should_not allows(:create) }
    it { should_not allows(:new) }
    it { should_not allows(:update) }
    it { should_not allows(:edit) }
    it { should_not allows(:destroy) }
    
    it "#permitted_attributes_for_create" do
      dns_record = build(:dns_record)
      dns_record_policy = described_class.new(used_user, dns_record)

      expect(dns_record_policy.permitted_attributes_for_update).to eq([])
    end

    it "#permitted_attributes_for_update" do
      dns_record = create(:dns_record)
      dns_record_policy = described_class.new(used_user, dns_record)

      expect(dns_record_policy.permitted_attributes_for_create).to eq([])
    end
  end

  describe "for a Non-community\'s User" do
    let(:used_user) { user }

    subject { described_class.new used_user, DnsRecord.new}
    
    it { should_not allows(:index) }
    it { should_not allows(:show) }
    it { should_not allows(:create) }
    it { should_not allows(:new) }
    it { should_not allows(:update) }
    it { should_not allows(:edit) }
    it { should_not allows(:destroy) }
    
    it "#permitted_attributes_for_create" do
      dns_record = build(:dns_record)
      dns_record_policy = described_class.new(used_user, dns_record)

      expect(dns_record_policy.permitted_attributes_for_update).to eq([])
    end

    it "#permitted_attributes_for_update" do
      dns_record = create(:dns_record)
      dns_record_policy = described_class.new(used_user, dns_record)

      expect(dns_record_policy.permitted_attributes_for_create).to eq([])
    end
  end

  describe "for a Non-community\'s User Admin" do
    let(:used_user) { user_admin }

    subject { described_class.new used_user, DnsRecord.new}
    
    it { should_not allows(:index) }
    it { should_not allows(:show) }
    it { should_not allows(:create) }
    it { should_not allows(:new) }
    it { should_not allows(:update) }
    it { should_not allows(:edit) }
    it { should_not allows(:destroy) }
    
    it "#permitted_attributes_for_create" do
      dns_record = build(:dns_record)
      dns_record_policy = described_class.new(used_user, dns_record)

      expect(dns_record_policy.permitted_attributes_for_update).to eq([])
    end

    it "#permitted_attributes_for_update" do
      dns_record = create(:dns_record)
      dns_record_policy = described_class.new(used_user, dns_record)

      expect(dns_record_policy.permitted_attributes_for_create).to eq([])
    end
  end

  describe "for a community member" do
    let!(:community) { Community.make! }
    let!(:dns_hosted_zone) { create :dns_hosted_zone, community: community }

    before do
      CommunityUser.create user: user, community: community, role: 1
    end

    subject { described_class.new user, DnsRecord.new(dns_hosted_zone: dns_hosted_zone)}

    it { should allows(:index) }
    it { should allows(:show) }
    it { should allows(:create) }
    it { should allows(:new) }
    it { should allows(:update) }
    it { should allows(:edit) }
    it { should allows(:destroy) }
    
    it "#permitted_attributes_for_create" do
      dns_record = build(:dns_record, dns_hosted_zone: dns_hosted_zone)
      dns_record_policy = described_class.new(user, dns_record)

      expect(dns_record_policy.permitted_attributes_for_create).to eq([ :name, :record_type, :value, :ttl ])
    end

    it "#permitted_attributes_for_update" do
      dns_record = create(:dns_record, dns_hosted_zone: dns_hosted_zone)
      dns_record_policy = described_class.new(user, dns_record)

      expect(dns_record_policy.permitted_attributes_for_update).to eq([ :record_type, :value, :ttl ])
    end
  end

end
