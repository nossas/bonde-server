require './app/resque_jobs/mailchimp_sync.rb'

RSpec.describe MailchimpSync, type: :resque_job do
	let(:widget_without_segment_id) { spy(:widget, :id => 1, :mailchimp_segment_id => nil) }
	let(:widget_with_segment_id) { spy(:widget, :id => 1, :mailchimp_segment_id => '123456') }


	describe '#perform' do
		context 'routing' do
			it 'Should correctly route to formEntry' do
				formEntry = spy(:formEntry, :synchronized => true)
				allow(FormEntry).to receive(:find).and_return(formEntry)
				MailchimpSync.perform 1, 'formEntry'
				expect(formEntry).to have_received(:synchronized).once
			end
			
			it 'Should correctly route to activist pressure' do
				activist_pressure = spy(:activist_pressure)
				allow(ActivistPressure).to receive(:find).and_return(activist_pressure)
				MailchimpSync.perform 1, 'activist_pressure'
				expect(activist_pressure).to have_received(:update_mailchimp).once
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
		it 'should not synchronize if don\'t have widget' do
			activist_pressure = spy(:activist_pressure, :id =>1, :widget => nil)
			allow(ActivistPressure).to receive(:find).and_return(activist_pressure)

			MailchimpSync.perform_with_activist_pressure 1

			expect(activist_pressure).not_to have_received(:update_mailchimp)
		end

		it 'should synchronize widget and activist_pressure if widget not synchronized' do
			activist_pressure = spy(:activist_pressure, :id =>1, :widget => widget_without_segment_id)
			allow(ActivistPressure).to receive(:find).and_return(activist_pressure)

			MailchimpSync.perform_with_activist_pressure 1

			expect(activist_pressure).to have_received(:update_mailchimp).once
			expect(widget_without_segment_id).to have_received(:create_mailchimp_segment).once
		end

		it 'should synchronize only activist_pressure if widget synchronized' do
			activist_pressure = spy(:activist_pressure, :id =>1, :widget => widget_with_segment_id)
			allow(ActivistPressure).to receive(:find).and_return(activist_pressure)

			MailchimpSync.perform_with_activist_pressure 1

			expect(activist_pressure).to have_received(:update_mailchimp).once
			expect(widget_with_segment_id).not_to have_received(:create_mailchimp_segment)
		end
	end



	describe '#perform_with_activist_match' do
		it 'should not synchronize if don\'t have widget' do
			activist_match = spy(:activist_match, :id =>1, :widget => nil)
			allow(ActivistMatch).to receive(:find).and_return(activist_match)

			MailchimpSync.perform_with_activist_match 1

			expect(activist_match).not_to have_received(:update_mailchimp)
		end

		it 'should synchronize widget and activist_match if widget not synchronized' do
			activist_match = spy(:activist_match, :id =>1, :widget => widget_without_segment_id)
			allow(ActivistMatch).to receive(:find).and_return(activist_match)

			MailchimpSync.perform_with_activist_match 1

			expect(activist_match).to have_received(:update_mailchimp).once
			expect(widget_without_segment_id).to have_received(:create_mailchimp_segment).once
		end

		it 'should synchronize only activist_pressure if widget synchronized' do
			activist_match = spy(:activist_match, :id =>1, :widget => widget_with_segment_id)
			allow(ActivistMatch).to receive(:find).and_return(activist_match)

			MailchimpSync.perform_with_activist_match 1

			expect(activist_match).to have_received(:update_mailchimp).once
			expect(widget_with_segment_id).not_to have_received(:create_mailchimp_segment)
		end
	end



	describe '#perform_with_formEntry' do
		it 'should not synchronize if don\'t have widget' do
			formEntry = spy(:formEntry, :id =>1, :widget => nil)
			allow(FormEntry).to receive(:find).and_return(formEntry)

			MailchimpSync.perform_with_formEntry 1

			expect(formEntry).not_to have_received(:send_to_mailchimp)
		end

		it 'should not synchronize if already synchronized' do
			formEntry = spy(:formEntry, :id =>1, :widget => widget_without_segment_id, :synchronized => true)
			allow(FormEntry).to receive(:find).and_return(formEntry)

			MailchimpSync.perform_with_formEntry 1

			expect(formEntry).not_to have_received(:create_mailchimp_segment)
			expect(widget_without_segment_id).not_to have_received(:send_to_mailchimp)
		end

		it 'should synchronize widget and formEntry if widget not synchronized' do
			formEntry = spy(:formEntry, :id =>1, :widget => widget_without_segment_id, :synchronized => false)
			allow(FormEntry).to receive(:find).and_return(formEntry)

			MailchimpSync.perform_with_formEntry 1

			expect(formEntry).to have_received(:send_to_mailchimp).once
			expect(widget_without_segment_id).to have_received(:create_mailchimp_segment).once
		end

		it 'should synchronize only formEntry if widget already synchronized' do
			formEntry = spy(:formEntry, :id =>1, :widget => widget_with_segment_id, :synchronized => false)
			allow(FormEntry).to receive(:find).and_return(formEntry)

			MailchimpSync.perform_with_formEntry 1

			expect(formEntry).to have_received(:send_to_mailchimp).once
			expect(widget_with_segment_id).not_to have_received(:create_mailchimp_segment)
		end
	end
end