require 'rails_helper'

RSpec.describe DnsHostedZone, type: :model do
  subject { build :dns_hosted_zone, community: (create :community) }

  it { should belong_to :community }
  it { should have_many :users }

  it { should validate_presence_of :community_id }
  it { should validate_presence_of :domain_name }
  it { should validate_length_of(:domain_name).is_at_most(255) }
end
