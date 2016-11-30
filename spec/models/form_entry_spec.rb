require 'rails_helper'

RSpec.describe FormEntry, type: :model do
	it { should belong_to :widget }
	it { should belong_to :activist }

	it { should validate_presence_of :fields }
	it { should validate_presence_of :widget }

	describe "Puts a message in Resque queue" do
		before do 
			@form_entry=FormEntry.make!
		end

		it "should save data in redis" do
			@form_entry.async_send_to_mailchimp

			resque_job = Resque.peek(:mailchimp_synchro)
            expect(resque_job).to be_present		
		end

		it "test the arguments" do
			@form_entry.async_send_to_mailchimp

			resque_job = Resque.peek(:mailchimp_synchro)
			expect(resque_job['args'][1]).to be_eql 'formEntry'
			expect(resque_job['args'].size).to be 2
		end
	end
end

