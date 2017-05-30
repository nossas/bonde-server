require 'rails_helper'

RSpec.describe PayableDetail, type: :model do
  let(:payment_date) { 1.days.ago }
  let(:waiting_funds_date) { 10.days.from_now }
  let(:community) { Community.make! }
  let(:user) { User.make! }
  let(:mobilization) { Mobilization.make!(community: community, user: user) }
  let(:block) { Block.make! mobilization: mobilization }
  let(:widget) { Widget.make!(kind: 'donation', block: block) }
  let(:widget_2) { Widget.make!(kind: 'donation', block: block) }
  let(:donation_pending) do
    Donation.make!(
      widget: widget,
      amount: 10,
      subscription: true,
      subscription_id: 123,
      transaction_status: 'paid',
      transaction_id: 1234,
      payables: [
        {
          id: 3992754,
          fee: 114,
          type: "credit",
          amount: 1000,
          object: "payable",
          status: "waiting_funds",
          installment: 1,
          date_created: "2016-09-05T22:29:49.060Z",
          payment_date: waiting_funds_date,
          recipient_id: community.recipient.pagarme_recipient_id,
          split_rule_id: nil,
          payment_method: "credit_card",
          transaction_id: 1234,
          anticipation_fee: 0,
          bulk_anticipation_id: nil,
          original_payment_date: nil
        }],
    )
  end
  let(:donation_paid) do
    Donation.make!(
      widget: widget_2,
      amount: 10,
      subscription: false,
      subscription_id: nil,
      transaction_status: 'paid',
      transaction_id: 12345,
      payables: [
        {
          id: 3102754,
          fee: 114,
          type: "credit",
          amount: 1000,
          object: "payable",
          status: "paid",
          installment: 1,
          date_created: "2016-09-05T22:29:49.060Z",
          payment_date: payment_date,
          recipient_id: community.recipient.pagarme_recipient_id,
          split_rule_id: nil,
          payment_method: "credit_card",
          transaction_id: 12345,
          anticipation_fee: 0,
          bulk_anticipation_id: nil,
          original_payment_date: nil
        }],
    )
  end
  let(:payable_transfer) { PayableTransfer.make! community: community}

  before do
    donation_paid
    donation_pending
  end

  describe 'is_paid' do
    subject { PayableDetail.is_paid }
    context "return only payables that is paid" do
      it { is_expected.to include(donation_paid.payable_details.first) }
      it { is_expected.not_to include(donation_pending.payable_details.first) }
    end
  end

  describe 'without_transfer' do
    before do
      payable_transfer
    end

    subject { PayableDetail.without_transfer.count }

    context "when has no transfer" do
      it { is_expected.to eq(2) }
    end

    context "when have transfer" do
      before do
        donation_paid.update_attribute :payable_transfer_id, payable_transfer.id
      end
      it { is_expected.to eq(1) }
    end
  end

  #describe 'over_limit_to_transfer' do
  #  subject { PayableDetail.over_limit_to_transfer }

  #  context "when org transfer_day is actual day" do
  #    before do
  #      community.update_attribute :transfer_day, DateTime.now.day
  #    end

  #    it "should return only payables that payable_date is already passed" do
  #      binding.pry
  #    end
  #  end

  #  context "when payable is for future" do
  #  end
  #end

  describe 'from_subscription' do
    subject { PayableDetail.from_subscription }
    context "return only payables that donations is from subscription" do
      it { is_expected.to include(donation_pending.payable_details.first) }
      it { is_expected.not_to include(donation_paid.payable_details.first) }
    end
  end

  describe 'by_mobilization' do
    context "return payables from a given mobilization" do
      it { expect(PayableDetail.by_mobilization(mobilization.id).count).to eq(2) }
      it { expect(PayableDetail.by_mobilization(87877).count).to eq(0) }
    end
  end

  describe 'by_widget' do
    context "return payables from a given widget" do
      it { expect(PayableDetail.by_widget(widget_2.id).count).to eq(1) }
      it { expect(PayableDetail.by_widget(widget.id).count).to eq(1) }
      it { expect(PayableDetail.by_widget(2).count).to eq(0) }
    end
  end

  describe 'by_block' do
    context "return payables from a given block" do
      it { expect(PayableDetail.by_block(block.id).count).to eq(2) }
      it { expect(PayableDetail.by_block(87877).count).to eq(0) }
    end
  end


end
