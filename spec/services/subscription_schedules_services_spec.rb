require 'rails_helper'

RSpec.describe SubscriptionSchedulesService do
  let(:subscription) { Subscription.make!(card_data: { id: 'card_xpto_id'}) }

  describe '#can_process' do
    let!(:donation) { Donation.make!(transaction_status: 'paid',
                                    created_at: '05/06/2018',
                                    local_subscription_id: subscription.id ) }

    before do
      create(:notification_template, label: 'paid_subscription')
      create(:notification_template, label: 'unpaid_subscription')
      subscription.transition_to(:paid)
      subscription.transitions.last.update_columns(created_at: DateTime.now - 1.month)
      subscription.reload
    end

    context 'when the next charges should be created' do
      it 'when the subscription it is paid and next charge is valid' do
        expect(SubscriptionSchedulesService.can_process(subscription)).to eq(true)
      end

      it 'when the subscription is unpaid and next reached charge is valid' do
        subscription.transition_to(:unpaid)
        donation.update_columns(transaction_status: 'refused')
        expect(SubscriptionSchedulesService.can_process(subscription)).to eq(true)
      end
    end

    context 'when the next charges should not be created' do
      it 'when the subscription is not paid and retry interval is less of community config' do
        subscription.transition_to(:unpaid)
        donation.update_columns(transaction_status: 'refused')
        donation.update_columns(created_at: DateTime.now - 6.days)
        expect(SubscriptionSchedulesService.can_process(subscription)).to eq(false)
      end

      it 'when the subscription is not paid, last_donation paid and retry interval is less of community config' do
        subscription.transition_to(:unpaid)
        donation.update_columns(transaction_status: 'paid')
        donation.update_columns(created_at: DateTime.now - 6.days)
        expect(SubscriptionSchedulesService.can_process(subscription)).to eq(false)
      end
    end
  end
end
