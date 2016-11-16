require './app/resque_jobs/mailchimp_sync.rb'

RSpec.describe MailchimpSync, type: :resque_job do
	describe '#perform' do
		context 'routing' do
			it 'Should correctly route to formEntry' do
				formEntry = spy(:formEntry, :synchronized => true)
				allow(FormEntry).to receive(:find).and_return(formEntry)
				MailchimpSync.perform 1, 'formEntry'
				expect(formEntry).to have_received(:synchronized).once
			end

			it 'Should correctly route to widget' do
				widget = spy(:widget)
				allow(Widget).to receive(:find).and_return(widget)
				MailchimpSync.perform 1, 'widget'
				expect(widget).to have_received(:create_mailchimp_segment).once
			end
			
			it 'Should correctly route to activist pressure' do
				@activist_pressure= spy(:activist_pressure)
				allow(ActivistPressure).to receive(:find).and_return(@activist_pressure)
				MailchimpSync.perform 1, 'activist_pressure'
				expect(@activist_pressure).to have_received(:update_mailchimp).once
			end

			it 'Should correctly route to activist match' do
				activist_matcher = spy(:activist_matcher)
				allow(ActivistMatch).to receive(:find).and_return(activist_matcher)
				MailchimpSync.perform 1, 'activist_match'
				expect(activist_matcher).to have_received(:update_mailchimp).once
			end
		end
	end

	describe '#perform_with_activist_pressure' do
		context 'widget is empty' do
			before do 
				@activist_pressure = spy(:activist_pressure, :id =>1, :widget => nil)
				allow(ActivistPressure).to receive(:find).and_return(@activist_pressure)
			end

			it 'Should been put on queue again' do
				MailchimpSync.perform_with_activist_pressure 1

				expect(@activist_pressure).to have_received(:async_update_mailchimp).once
			end
		end

		context 'if widget is not saved put on list again' do
			before do 
				@activist_pressure = spy(:activist_pressure, :id =>1, :widget => spy(:widget, :id=>nil))
				allow(ActivistPressure).to receive(:find).and_return(@activist_pressure)
			end

			it 'Should been put on queue again' do
				MailchimpSync.perform_with_activist_pressure 1

				expect(@activist_pressure).to have_received(:async_update_mailchimp).once
			end
		end
	end

	describe '#perform_with_activist_match' do
		context 'correct and suficient data' do
			before do 
				@activist_matcher= spy(:activist_matcher)
				allow(ActivistMatch).to receive(:find).and_return(@activist_matcher)
			end

			it 'Should correctly route to activist match' do
				MailchimpSync.perform_with_activist_match 1
				expect(@activist_matcher).to have_received(:update_mailchimp).once
			end
		end

		context 'Activist is empty' do
			before do 
				@activist_match = spy(:activist_match, :id =>1, :activist => nil)
				allow(ActivistMatch).to receive(:find).and_return(@activist_match)
			end

			it 'should be reput on queue' do
				MailchimpSync.perform_with_activist_match 1

	            expect(@activist_match).to have_received(:async_update_mailchimp).once
			end
		end

		context 'Activist exists, but it is not saved' do
			before do 
				@activist_match = spy(:activist_match, :id =>1, :activist => spy(:activist, :id=>nil))
				allow(ActivistMatch).to receive(:find).and_return(@activist_match)
			end

			it 'should be reput on queue' do
				MailchimpSync.perform_with_activist_match 1

	            expect(@activist_match).to have_received(:async_update_mailchimp).once
			end
		end

		context 'Match is null' do
			before do 
				@activist_match = spy(:activist_match, :id =>1, :match => nil)
				allow(ActivistMatch).to receive(:find).and_return(@activist_match)
			end

			it 'should be reput on queue' do
				MailchimpSync.perform_with_activist_match 1

	            expect(@activist_match).to have_received(:async_update_mailchimp).once
			end
		end

		context 'Match exists, but it is not saved' do
			before do 
				@activist_match = spy(:activist_match, :id =>1, :match => spy(:match, :id=>nil))
				allow(ActivistMatch).to receive(:find).and_return(@activist_match)
			end

			it 'should be reput on queue' do
				MailchimpSync.perform_with_activist_match 1

	            expect(@activist_match).to have_received(:async_update_mailchimp).once
			end
		end
	end

	describe '#perform_with_formEntry' do
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
			it 'should not put it back on queue' do
				expect(@formEntry).not_to have_received(:async_send_to_mailchimp)
			end
		end
		
		context 'widget\'s mailchimp_segment_id doesn\'t been setted'  do
			before do 
				@spy_widget = spy(:widget, :mailchimp_segment_id => nil)
				@formEntry = spy(:formEntry, :id => 1, :synchronized => false, :widget => @spy_widget )
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

			it 'should call widget\'s async_create_mailchimp_segment' do
				expect(@spy_widget).to have_received(:async_create_mailchimp_segment)
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