require 'rails_helper'

RSpec.describe ActivistMatch, type: :model do
  subject { ActivistMatch.make( activist: Activist.make!) }

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

  describe '#update_mailchimp' do
    before do
       stub_request(:post, "https://us6.api.mailchimp.com/3.0/lists/#{ENV['MAILCHIMP_LIST_ID']}/members").
         with(:body => "{\"email_address\":\"foo@bar.org\",\"status\":\"subscribed\",\"merge_fields\":{\"FNAME\":null,\"LNAME\":null,\"EMAIL\":\"foo@bar.org\"}}").
         to_return(:status => 200, :body => "", :headers => {})

     stub_request(:patch, "https://us6.api.mailchimp.com/3.0/lists/#{ENV['MAILCHIMP_LIST_ID']}/members/24191827e60cdb49a3d17fb1befe951b").
         to_return(:status => 200, :body => "", :headers => {})
    end

    it { subject.update_mailchimp(force_in_test: true)}
  end
end
