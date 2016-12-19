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

  describe "Puts a message in Resque queue" do
    before do 
      Resque.redis.flushall
      activistMatch=ActivistMatch.new id: 12
      activistMatch.async_update_mailchimp
      @resque_job = Resque.peek(:mailchimp_synchro)
    end

    it "should save data in redis" do
      expect(@resque_job).to be_present   
    end

    it "test the arguments" do
      expect(@resque_job['args'][0]).to be_eql 12
      expect(@resque_job['args'][1]).to be_eql 'activist_match'
      expect(@resque_job['args'].size).to be 2
    end
  end
end
