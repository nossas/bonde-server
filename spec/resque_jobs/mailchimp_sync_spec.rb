require './app/resque_jobs/mailchimp_sync.rb'

RSpec.describe MailchimpSync, type: :resque_job do
	describe 'perform testing' do
		context 'if synchronized status = false' do
			before do 
				@formEntry = spy(:formEntry, :id => 1, :synchronized => false )
				allow(FormEntry).to receive(:find).and_return(@formEntry)
				MailchimpSync.perform 1
			end

			it 'should save the data' do
				expect(@formEntry).to have_received(:save).with(no_args).once
			end

			it 'should call send_to_mailchimp method' do
				expect(@formEntry).to have_received(:send_to_mailchimp).with(no_args).once
			end

			it 'should change the synchronized status' do
				expect(@formEntry).to have_received(:synchronized=).with(true).once
			end
		end

		context 'if synchronized status = true' do
			before do 
				@formEntry = spy(:formEntry, :id => 1, :synchronized => true )
				allow(FormEntry).to receive(:find).and_return(@formEntry)
				MailchimpSync.perform 1
			end

			it 'should NOT save the data' do
				expect(@formEntry).not_to have_received(:save).with(no_args)
			end

			it 'should NOT call send_to_mailchimp method' do
				expect(@formEntry).not_to have_received(:send_to_mailchimp).with(no_args)
			end

			it 'should NOT change the synchronized status' do
				expect(@formEntry).not_to have_received(:synchronized=)
			end
		end
	end
end