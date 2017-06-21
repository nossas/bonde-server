require 'rails_helper'

RSpec.describe Community, type: :model do
  it { should validate_presence_of :name }

  it { should have_many :payable_transfers }
  it { should have_many :payable_details }
  it { should have_many :mobilizations }
  it { should have_many :community_users }
  it { should have_many :users }
  it { should have_many :recipients }
  it { should have_many :dns_hosted_zones }

  it { should belong_to :recipient }

  it { should validate_uniqueness_of :name }

  describe '#invite_member' do
    let(:community) { create(:community)}
    it do
      expect_any_instance_of(Invitation).to receive(:invitation_email).once

      community.invite_member 'ask@me', create(:user), 1
    end
  end
end
