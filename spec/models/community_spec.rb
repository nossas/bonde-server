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

  describe '#resync_all' do
    let(:community) { create(:community)}

    context 'when not sent resync yet' do
      before do
        expect(community).to receive(:update_column).with(:mailchimp_sync_request_at, anything)
        expect(CommunityMailchimpResyncWorker).to receive(:perform_async).with(community.id)
      end

      it 'should call community resync worker' do
        community.resync_all
      end
    end

    context 'when last requested at is in 10 minutes window' do

      before do
        community.update_column(:mailchimp_sync_request_at, 5.minutes.ago)
        expect(community).to_not receive(:update_column).with(:mailchimp_sync_request_at, anything)
        expect(CommunityMailchimpResyncWorker).to_not receive(:perform_async).with(community.id)
      end

      it 'should call community resync worker' do
        community.resync_all
      end
    end

    context 'when last requested at is greater 10 minutes window' do
      before do
        community.update_column(:mailchimp_sync_request_at, 11.minutes.ago)
        expect(community).to receive(:update_column).with(:mailchimp_sync_request_at, anything)
        expect(CommunityMailchimpResyncWorker).to receive(:perform_async).with(community.id)
      end

      it 'should call community resync worker' do
        community.resync_all
      end
    end
  end
end
