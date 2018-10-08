require 'rails_helper'

RSpec.describe SubscriptionSchedulesService do

  let(:subscription) { Subscription.make!(card_data: { id: 'card_xpto_id'}) }

  describe '#can_process' do
    let!(:donation) { Donation.make!(transaction_status: 'paid', created_at: '05/06/2018', local_subscription_id: subscription.id ) }

    before do
      create(:notification_template, label: 'paid_subscription')
      create(:notification_template, label: 'unpaid_subscription')
      subscription.transition_to(:paid)
      subscription.transitions.last.update_columns(created_at: DateTime.now - 1.month)
      subscription.reload
    end

    context 'when the next charges should be created' do
      it 'when the subscription it is paid and next charge is valid' do
        expect(SubscriptionSchedulesService.can_process?(subscription)).to eq(true)
      end

      it 'when the subscription is unpaid and next reached charge is valid' do
        subscription.transition_to(:unpaid)
        donation.update_columns(transaction_status: 'refused')
        expect(SubscriptionSchedulesService.can_process?(subscription)).to eq(true)
      end
    end

    context 'when the next charges should not be created' do
      it 'when the subscription is not paid and retry interval is less of community config' do
        subscription.transition_to(:unpaid)
        donation.update_columns(transaction_status: 'refused')
        donation.update_columns(created_at: DateTime.now - 6.days)
        expect(SubscriptionSchedulesService.can_process?(subscription)).to eq(false)
      end

      it 'when the subscription is not paid, last_donation paid and retry interval is less of community config' do
        subscription.transition_to(:unpaid)
        donation.update_columns(transaction_status: 'paid')
        donation.update_columns(created_at: DateTime.now - 6.days)
        expect(SubscriptionSchedulesService.can_process?(subscription)).to eq(false)
      end
    end

    context 'when the subscription has more donations unpaid' do
      let!(:donation_1) { Donation.make!(transaction_status: 'refused', created_at: '05/04/2018', local_subscription_id: subscription.id) }

      let!(:donation_2) { Donation.make!(transaction_status: 'refused', created_at: '05/05/2018', local_subscription_id: subscription.id) }

      let!(:donation_3) { Donation.make!(transaction_status: 'refused', created_at: '05/06/2018', local_subscription_id: subscription.id) }

      it 'when the subscription must have more donations with last three unpaid and can be processed' do
        subscription.transition_to(:unpaid)
        donation.update_columns(created_at: DateTime.now - 4.months)
        expect(SubscriptionSchedulesService.can_process?(subscription)).to eq(true)
      end

      it 'when the subscription must have more donations and not can be processed' do
        subscription.transition_to(:unpaid)
        donation.update_columns(created_at: DateTime.now - 4.months)
        donation_3.update_columns(created_at: DateTime.now - 2.days)
        expect(SubscriptionSchedulesService.can_process?(subscription)).to eq(false)
      end
    end

    context 'when the subscription was processed 3 times, should be process again but should not send a notification unpaid' do
      let(:subs) { Subscription.make!(card_data: { id: 'card_xpto_id'}) }
      let!(:donation_1) { Donation.make!(transaction_status: 'paid', created_at: '05/03/2018', local_subscription_id: subs.id) }
      let!(:donation_2) { Donation.make!(transaction_status: 'refused', created_at: '05/04/2018', local_subscription_id: subs.id) }
      let!(:donation_3) { Donation.make!(transaction_status: 'refused', created_at: '05/05/2018', local_subscription_id: subs.id) }
      let!(:donation_4) { Donation.make!(transaction_status: 'refused', created_at: '05/06/2018', local_subscription_id: subs.id) }
      let!(:donation_5) { Donation.make!(transaction_status: 'refused', created_at: '05/07/2018', local_subscription_id: subs.id) }

      it 'should not generate notification' do
        subs.transition_to(:paid)
        subs.transition_to(:unpaid)
        subs.transition_to(:unpaid)
        subs.transition_to(:unpaid)
        subs.transition_to(:unpaid)
        donation_5.update_columns(created_at: DateTime.now - 4.months)
        notifications = Notification.where("template_vars->>'subscription_id' = ?", subs.id.to_s)

        expect(SubscriptionSchedulesService.can_process?(subs)).to eq(true)
        expect(subs.reached_notification_limit?).to eq(true)
        expect(notifications.count).to eq(4)
      end
    end
  end
end
