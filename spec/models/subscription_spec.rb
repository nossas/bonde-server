require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it { should belong_to :widget }
  it { should belong_to :activist }
  it { should belong_to :community }

  it { should have_many :donations }

  let(:subscription) { Subscription.make!(card_data: { id: 'card_xpto_id'}) }

  before do
    allow(subscription).to receive(:notify_activist)
  end

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

  describe "payment_options_to_use" do
    let(:card_hash) { nil }
    subject { subscription.payment_options_to_use(card_hash) }
    context "when subscription payment method is" do
      context "boleto" do
        before do
          subscription.payment_method = 'boleto'
          subscription.save
        end
        it { is_expected.to eq({}) }
      end

      context "credit card" do
        it { is_expected.to eq({card_id: 'card_xpto_id'}) }
      end

      context "with card hash" do
        let(:card_hash) { 'xpto' }
        it { is_expected.to eq({card_hash: 'xpto'}) }
      end
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

  describe "charge_next_payment" do
    let(:card_hash) { nil }
    subject { subscription.charge_next_payment(card_hash) }

    context "when is not in the time to charge new payments" do
      let!(:paid_donation_1) do
        Donation.make!(
          transaction_status: 'paid',
          created_at: DateTime.now,
          local_subscription_id: subscription.id,
          gateway_data: { customer: { id: '12345' } }.to_json
        )
      end

      it "should return nil" do
        is_expected.to eq(nil)
      end
    end

    context "when is in time to next charge" do
      let(:transaction) do
        double(
          {
            id: '1235',
            status: 'paid',
            payables: [{id: 'x'}, {id: 'y'}],
            card: { id: 'card_xpto_id'},
            charge: true
          })
      end
      let(:pagarme_attributes) do
        {
          card_id: 'card_xpto_id',
          customer: { id: '12345' },
          postback_url: Rails.application.routes.url_helpers.create_postback_url(protocol: 'https'),
          amount: subscription.amount,
          split_rules: subscription.base_rules,
          metadata: {
            widget_id: subscription.widget.id,
            mobilization_id: subscription.widget.mobilization.id,
            community_id: subscription.community.id,
            city: subscription.community.city,
            email: subscription.activist.email,
            donation_id: (subscription.donations.last.id + 1),
            local_subscription_id: subscription.id
          }
        }
      end
      context "when have not pending payments" do
        let!(:paid_donation_1) do
          Donation.make!(
            transaction_status: 'paid',
            created_at: 31.days.ago,
            local_subscription_id: subscription.id,
            gateway_data: { customer: { id: '12345' } }.to_json
          )
        end
        context "and payment is waiting_payment" do
          let(:transaction) do
            double(
              {
                id: '1235',
                status: 'waiting_payment',
                payables: [{id: 'x'}, {id: 'y'}],
                card: nil,
                boleto_url: 'url_boleto',
                boleto_barcode: 'barcode',
                boleto_expiraton_date: '17-01-2018',
                charge: true
              })
          end
          before do
            expect(PagarMe::Transaction).to receive(:new).with(pagarme_attributes).and_return(transaction)
          end

          it 'should charge and update generated donation' do
            expect(subscription).to receive(:notify_activist).with(:slip_subscription)
            expect(subscription).not_to receive(:transition_to)
            expect(SubscriptionWorker).not_to receive(:perform_at).with(anything, subscription.id).and_call_original
            charged = subject
            expect(charged.transaction_id).to eq("1235")
            expect(charged.transaction_status).to eq('waiting_payment')
            expect(subscription.current_state).to eq('pending')
            expect(SubscriptionWorker.jobs.size).to eq(0)
            expect(SubscriptionWorker.jobs.any?{ |j| j['args'][0] == subscription.id }).to eq(false)
          end

        end
        context "and payment is pending"do
          let(:transaction) do
            double(
              {
                id: '1235',
                status: 'processing',
                payables: [{id: 'x'}, {id: 'y'}],
                card: { id: 'card_xpto_id'},
                charge: true
              })
          end
          before do
            expect(PagarMe::Transaction).to receive(:new).with(pagarme_attributes).and_return(transaction)
          end

          it 'should charge and update generated donation' do
            expect(subscription).not_to receive(:notify_activist)
            expect(subscription).not_to receive(:transition_to)
            expect(SubscriptionWorker).not_to receive(:perform_at).with(anything, subscription.id).and_call_original
            charged = subject
            expect(charged.transaction_id).to eq("1235")
            expect(charged.transaction_status).to eq('processing')
            expect(subscription.current_state).to eq('pending')
            expect(SubscriptionWorker.jobs.size).to eq(0)
            expect(SubscriptionWorker.jobs.any?{ |j| j['args'][0] == subscription.id }).to eq(false)
          end
        end

        context "and payment is paid" do
          before do
            expect(PagarMe::Transaction).to receive(:new).with(pagarme_attributes).and_return(transaction)
          end

          it 'should charge and update generated donation' do
            expect(subscription).to receive(:notify_activist).with(:paid_subscription)
            expect(subscription).to receive(:transition_to).with(:paid, anything).and_call_original
            expect(SubscriptionWorker).to receive(:perform_at).with(anything, subscription.id).and_call_original
            charged = subject
            expect(charged.transaction_id).to eq("1235")
            expect(charged.transaction_status).to eq('paid')
            expect(subscription.current_state).to eq('paid')
            expect(SubscriptionWorker.jobs.size).to eq(1)
            expect(SubscriptionWorker.jobs.any?{ |j| j['args'][0] == subscription.id }).to eq(true)
          end
        end

        context "and payment is refused" do
          let(:transaction) do
            double(
              {
                id: '1235',
                status: 'refused',
                payables: [{id: 'x'}, {id: 'y'}],
                card: { id: 'card_xpto_id'},
                charge: true
              })
          end
          before do
            expect(PagarMe::Transaction).to receive(:new).with(pagarme_attributes).and_return(transaction)
          end
          it 'should charge and update generated donation' do
            expect(subscription).to receive(:notify_activist).with(:unpaid_subscription)
            expect(subscription).to receive(:transition_to).with(:unpaid, anything).and_call_original
            expect(SubscriptionWorker).not_to receive(:perform_at).with(anything, subscription.id)
            charged = subject
            expect(charged.transaction_id).to eq("1235")
            expect(charged.transaction_status).to eq('refused')
            expect(subscription.current_state).to eq('unpaid')
            expect(SubscriptionWorker.jobs.size).to eq(0)
            expect(SubscriptionWorker.jobs.any?{ |j| j['args'][0] == subscription.id }).to eq(false)
          end
        end

        context 'when payment is refused again' do
          let(:transaction) do
            double(
              {
                id: '1235',
                status: 'refused',
                payables: [{id: 'x'}, {id: 'y'}],
                card: { id: 'card_xpto_id'},
                charge: true
              })
          end
          before do
            subscription.transition_to(:unpaid)
            expect(PagarMe::Transaction).to receive(:new).with(pagarme_attributes).and_return(transaction)
          end
          it 'should charge and update generated donation' do
            expect(subscription).to receive(:notify_activist).with(:unpaid_after_charge_subscription)
            expect(subscription).to receive(:transition_to).with(:unpaid, anything).and_call_original
            expect(SubscriptionWorker).not_to receive(:perform_at).with(anything, subscription.id)
            charged = subject
          end

        end

      end
    end

  end

  describe "base_rules" do
    before do
      ENV['ORG_RECIPIENT_ID'] = '1234'
    end

    subject { subscription.base_rules }

    context "when global recipient is not the same of community" do
      before do
        pagarme_recipient = double({pagarme_recipient_id: '123'})
        allow(subscription.community).to receive(:recipient).and_return(pagarme_recipient)
      end

      it "should return the global and community rules in array" do
        is_expected.to eq([subscription.global_rule, subscription.community_rule])
      end
    end

    context "when global recipient is the same of community" do
      before do
        pagarme_recipient = double({pagarme_recipient_id: '1234'})
        allow(subscription.community).to receive(:recipient).and_return(pagarme_recipient)
      end

      it "should return only the global rule on array with 100 on percentage" do
        is_expected.to eq([subscription.global_rule({percentage: 100})])
      end
    end
  end

  describe "global_rule" do
    before do
      ENV['ORG_RECIPIENT_ID'] = '1234'
    end

    subject { subscription.global_rule }

    it "should return the global split rule" do
      expect(subject.charge_processing_fee).to eq(true)
      expect(subject.liable).to eq(false)
      expect(subject.percentage).to eq(13)
      expect(subject.recipient_id).to eq("1234")
    end
  end

  describe "community_rule" do
    before do
      allow(subscription.community).to receive(:recipient).and_return(double(
                                                                         {
                                                                           pagarme_recipient_id: '123'
                                                                         }
                                                                       ))
    end

    subject { subscription.community_rule }

    it "should return the community split rule" do
      expect(subject.charge_processing_fee).to eq(false)
      expect(subject.liable).to eq(true)
      expect(subject.percentage).to eq(87)
      expect(subject.recipient_id).to eq("123")
    end
  end
end
