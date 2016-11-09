require './app/resque_jobs/mailchimp_sync.rb'

RSpec.describe MailchimpSync, type: :resque_job do
	describe 'method perform is performing :) the correct routing to formEntry' do
		before do 
			@formEntry = spy(:formEntry, :synchronized => true)
			allow(FormEntry).to receive(:find).and_return(@formEntry)
		end

		it 'test routing with formEntry' do
			MailchimpSync.perform 1, 'formEntry'
			expect(@formEntry).to have_received(:synchronized).once
		end
	end

	describe 'method perform is performing :) the correct routing to widget' do
		before do 
			@widget= spy(:widget)
			allow(Widget).to receive(:find).and_return(@widget)
		end

		it 'Test routing with widget' do
			MailchimpSync.perform 1, 'widget'
			expect(@widget).to have_received(:create_mailchimp_segment).once
		end
	end

	describe 'method perform_with_formEntry testing' do
		context 'widget doesn\'t been setted'  do
			before do 
				@formEntry = spy(:formEntry, :id => 1, :synchronized => false, :widget => nil )
				allow(FormEntry).to receive(:find).and_return(@formEntry)
				MailchimpSync.perform_with_formEntry 1
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
			it 'should put it back on queue' do
				expect(@formEntry).to have_received(:async_send_to_mailchimp)
			end
		end
		
		context 'widget\'s mailchimp_segment_id doesn\'t been setted'  do
			before do 
				fake_widget = double(:widget, :mailchimp_segment_id => nil)
				@formEntry = spy(:formEntry, :id => 1, :synchronized => false, :widget => fake_widget )
				allow(FormEntry).to receive(:find).and_return(@formEntry)
				MailchimpSync.perform_with_formEntry 1
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
			it 'should put it back on queue' do
				expect(@formEntry).to have_received(:async_send_to_mailchimp)
			end
		end

		context 'with widget and it\'s mailchimp_segment_id setted up' do
			before do 
				@fake_widget = double(:widget, :mailchimp_segment_id => '12312356745')
			end

			context 'if synchronized status = false' do
				before do 
					@formEntry = spy(:formEntry, :id => 1, :synchronized => false, :widget => @fake_widget )
					allow(FormEntry).to receive(:find).and_return(@formEntry)
					MailchimpSync.perform_with_formEntry 1
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
					@formEntry = spy(:formEntry, :id => 1, :synchronized => true, :widget => @fake_widget )
					allow(FormEntry).to receive(:find).and_return(@formEntry)
					MailchimpSync.perform_with_formEntry 1
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
end