require 'rails_helper'

RSpec.describe ActivistMatch, type: :model do
  it { should belong_to :activist }
  it { should belong_to :match }
  it { should validate_presence_of :widget }
  it { should validate_presence_of :activist }
  it { should have_one :widget }
  it { should have_one :block }
  it { should have_one :mobilization }
  it { should have_one :community }

  describe "Puts a message in sidekiq queue" do
    before do 
      activistMatch=ActivistMatch.new id: 12
      activistMatch.async_update_mailchimp
    end

    it "should save data in redis" do
      sidekiq_jobs = MailchimpSyncWorker.jobs
      expect(sidekiq_jobs.size).to eq(1)
      expect(sidekiq_jobs.last['args']).to eq([12, 'activist_match'])
    end
  end
end
