require 'rails_helper'

RSpec.describe ActivistMatch, type: :model do
  subject { build :activist_match }

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
    let(:mailchimp_list_id) { 9989 }
    subject { create :activist_match }

    before do
      subject.community.update_attributes mailchimp_api_key: "8b0bd9c101204efdc538affee79c4b06-us8", mailchimp_list_id: mailchimp_list_id

      stub_request(:post, "https://us8.api.mailchimp.com/3.0/lists/#{mailchimp_list_id}/members").
        to_return(:status => 200, :body => "", :headers => {})

       stub_request(:patch, /\Ahttps\:\/\/us8\.api\.mailchimp\.com\/3\.0\/lists\/#{mailchimp_list_id}\/members\// ).
         to_return(:status => 200, :body => "", :headers => {})
    end

    it { subject.update_mailchimp(force_in_test: true)}
  end
end
