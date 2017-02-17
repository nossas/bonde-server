require 'rails_helper'

RSpec.describe Donation, type: :model do
  it { should belong_to :widget }
  it { should belong_to :activist }
  it { should belong_to :subscription_relation }

  it { should have_one :mobilization }
  it { should have_one :community }

  it { should belong_to :parent }
  it { should belong_to :payable_transfer }

  it { should have_many :payments }
  it { should have_many :payable_details }

  describe '#async_update_mailchimp' do
    let(:donation) { Donation.new id: 52 }
    let(:resque_job) { Resque.peek(:mailchimp_synchro) }

    before do 
      Resque.redis.flushall
      donation.async_update_mailchimp
    end

    it "should save data in redis" do
      expect(resque_job).to be_present   
    end

    it "test the arguments" do
      expect(resque_job['args'][0]).to be_eql 52
      expect(resque_job['args'][1]).to be_eql 'donation'
      expect(resque_job['args'].size).to be 2
    end
  end

  describe 'scopes' do
    context 'paid' do
      before do
        3.times { Donation.make! transaction_status: 'paid' }
        4.times { Donation.make! transaction_status: 'pending' }
        2.times { Donation.make! transaction_status: 'refused' }
      end

      subject { Donation.paid.count }
      it { is_expected.to eq(3) }
    end
  end
end
