require 'rails_helper'

RSpec.describe DnsRecord, type: :model do
  subject { create :dns_record }
  it { should belong_to :dns_hosted_zone }
  it { should have_one :community }
  it { should have_many :users }
  
  it { should validate_presence_of :dns_hosted_zone_id }
  it { should validate_presence_of :name }
  it { should validate_presence_of :record_type }
  it { should validate_presence_of :value }
  it { should validate_presence_of :ttl }
end
