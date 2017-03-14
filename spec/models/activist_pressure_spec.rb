require 'rails_helper'

RSpec.describe ActivistPressure, type: :model do
  it { should belong_to :widget }
  it { should belong_to :activist }
  it { should validate_presence_of :widget }
  it { should have_one :block }
  it { should have_one :mobilization }
  it { should have_one :community }

  describe "Puts a message in sidekiq queue" do
    before do 
      activistPressure=ActivistPressure.new id:15
      activistPressure.async_update_mailchimp
    end

    it "should save data in sidekiq" do
      sidekiq_jobs = MailchimpSyncWorker.jobs
      expect(sidekiq_jobs.size).to eq(1)
      expect(sidekiq_jobs.last['args']).to eq([15, 'activist_pressure'])
    end
  end
end
