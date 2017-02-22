require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it { should belong_to :widget }
  it { should belong_to :activist }
  it { should belong_to :community }

  it { should have_many :donations }

  let(:subscription) { Subscription.make!(card_data: { id: 'card_xpto_id'}) }

  describe "last_charge" do
    let!(:paid_donation_1) { Donation.make!(
                              transaction_status: 'paid',
                              created_at: '01/01/2017',
                              local_subscription_id: subscription.id ) }
    let!(:pending_donation_1) { Donation.make!(
                               transaction_status: 'pending',
                               created_at: '01/02/2017',
                               local_subscription_id: subscription.id ) }
    let!(:paid_donation_2) { Donation.make!(
                              transaction_status: 'paid',
                              created_at: '01/02/2017',
                              local_subscription_id: subscription.id ) }
    subject { subscription.last_charge }

    context "should return the last paid payment on subscription" do
      it { is_expected.to eq(paid_donation_2)}
    end
  end

  describe "next_transaction_charge_date" do
    context "when subscriptions is new without donations" do
      subject { subscription.next_transaction_charge_date.to_date }
      it { is_expected.to eq(DateTime.now.to_date) }
    end

    context "when subscription already have charged donations" do
      subject { subscription.next_transaction_charge_date.to_date }
      let!(:paid_donation_1) { Donation.make!(
                                transaction_status: 'paid',
                                created_at: '01/01/2017',
                                local_subscription_id: subscription.id ) }

      it { is_expected.to eq('01/02/2017'.to_date) }
    end
  end

  describe "customer" do
    subject { subscription.customer }
    context "when have a last charged donation" do
      let!(:paid_donation_1) do
        Donation.make!(
          transaction_status: 'paid',
          created_at: '01/01/2017',
          local_subscription_id: subscription.id,
          gateway_data: { customer: { id: '12345' } }.to_json
        )
      end

      it { is_expected.to eq({"id" => "12345"}) }
    end

    context "when not have chaged but some pendings" do
      let!(:pending_donation_1) do
        Donation.make!(
          transaction_status: 'pending',
          created_at: '01/02/2017',
          local_subscription_id: subscription.id ,
          gateway_data: { customer: { id: '12345' } }.to_json
        )
      end

      it { is_expected.to eq({"id" => "12345"}) }
    end
  end

end
