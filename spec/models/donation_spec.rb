require 'rails_helper'

RSpec.describe Donation, type: :model do
  it { should belong_to :widget }
  it { should belong_to :activist }

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
      donation.async_update_mailchimp
    end

    it "should save data in sidekiq" do
      sidekiq_jobs = MailchimpSyncWorker.jobs
      expect(sidekiq_jobs.size).to eq(1)
      expect(sidekiq_jobs.last['args']).to eq([donation.id, 'donation'])
    end
  end
end
