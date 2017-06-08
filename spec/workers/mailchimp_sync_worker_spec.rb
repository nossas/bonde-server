require 'rails_helper'
RSpec.describe MailchimpSyncWorker, type: :worker do
	let(:widget_without_segment_id) { spy(:widget, :id => 1, :mailchimp_segment_id => nil) }
	let(:widget_with_segment_id) { spy(:widget, :id => 1, :mailchimp_segment_id => '123456') }
  let(:worker) { MailchimpSyncWorker.new }

  before do
    Sidekiq::Testing.inline!
  end


	describe '#perform' do
    context do
      before do
        allow_any_instance_of(MailchimpSyncWorker).to receive(:perform_with)
      end

  		it 'Should correctly route to formEntry' do
  			formEntry = spy(:formEntry, :synchronized => true)
      	allow(FormEntry).to receive(:find).and_return(formEntry)

  			worker.perform 1, 'formEntry'

  			expect(worker).to have_received(:perform_with).with(formEntry).once
  		end

  		it 'Should correctly route to activist pressure' do
  			activist_pressure = spy(:activist_pressure, :synchronized => true)
  			allow(ActivistPressure).to receive(:find).and_return(activist_pressure)

  			worker.perform 1, 'activist_pressure'
        expect(worker).to have_received(:perform_with).with(activist_pressure).once
      end

      it 'Should correctly route to activist match' do
        activist_matcher = spy(:activist_matcher, :synchronized => true)
        allow(ActivistMatch).to receive(:find).and_return(activist_matcher)

        worker.perform 1, 'activist_match'

        expect(worker).to have_received(:perform_with).with(activist_matcher).once
      end

      it 'Should correctly route to donation' do
        donation = spy(:donation, :synchronized => true)
        allow(Donation).to receive(:find).and_return(donation)
        
        worker.perform 1, 'donation'

        expect(worker).to have_received(:perform_with).with(donation).once
      end
    end

    it 'Should correctly route to subcription' do
      allow_any_instance_of(MailchimpSyncWorker).to receive(:perform_subscription)
      
      subscription = spy(:subscription, :synchronized => true)
      allow(Subscription).to receive(:find).and_return(subscription)
      
      worker.perform 1, 'subscription'

			expect(worker).to have_received(:perform_subscription).with(subscription).once
    end
	end



  describe '#perform_with' do
    it 'should not synchronize if don\'t have widget' do
      activist_pressure = spy(:activist_pressure, :id =>1, :widget => nil)
      
      worker.perform_with activist_pressure

      expect(activist_pressure).not_to have_received(:update_mailchimp)
    end

    it 'should not synchronize if don\'t have widget' do
      activist_pressure = spy(:activist_pressure, :id =>1, :widget => nil)
      
      worker.perform_with activist_pressure

      expect(activist_pressure).not_to have_received(:update_mailchimp)
    end

    it 'should not synchronize if activist_pressure already synchronized' do
      activist_pressure = spy(:activist_pressure, :id =>1, :widget => widget_with_segment_id, :synchronized => true)
      
      worker.perform_with activist_pressure

			expect(activist_pressure).not_to have_received(:update_mailchimp)
			expect(widget_with_segment_id).not_to have_received(:create_mailchimp_segment)
		end

		it 'should synchronize widget and activist_pressure if widget not synchronized' do
			activist_pressure = spy(:activist_pressure, :id =>1, :widget => widget_without_segment_id, :synchronized => false)
      
      worker.perform_with activist_pressure

			expect(activist_pressure).to have_received(:update_mailchimp).once
			expect(widget_without_segment_id).to have_received(:create_mailchimp_segment).once
		end

		it 'should synchronize only activist_pressure if already widget synchronized' do
			activist_pressure = spy(:activist_pressure, :id =>1, :widget => widget_with_segment_id, :synchronized => false)
      
      worker.perform_with activist_pressure

			expect(activist_pressure).to have_received(:update_mailchimp).once
			expect(widget_with_segment_id).not_to have_received(:create_mailchimp_segment)
		end
	end

  describe '#perform_subscription' do

    it 'should do nothing if already synchronized' do
      subscription = spy(:subscription, :synchronized => true)
      worker.perform_subscription subscription

      expect(subscription).not_to have_received(:mailchimp_remove_from_active_donators)
      expect(subscription).not_to have_received(:mailchimp_add_active_donators)
      expect(subscription).not_to have_received(:save!)
    end

    it 'should add to segment if status is paid' do
      subscription = spy(:subscription, :id =>1, :widget => widget_with_segment_id, :synchronized => false, :status => 'paid', current_state: 'paid')
      worker.perform_subscription subscription

      expect(subscription).not_to have_received(:mailchimp_remove_from_active_donators)
      expect(subscription).to have_received(:mailchimp_add_active_donators)
      expect(subscription).to have_received(:save!)
    end

    ['unpaid', 'canceled'].each do |status|
      it "should add to segment if status is #{status}" do
        subscription = spy(:subscription, :id =>1, :widget => widget_with_segment_id, :synchronized => false, :status => status, current_state: status)
        worker.perform_subscription subscription

        expect(subscription).to have_received(:mailchimp_remove_from_active_donators)
        expect(subscription).not_to have_received(:mailchimp_add_active_donators)
        expect(subscription).to have_received(:save!)
      end
    end
  end
end