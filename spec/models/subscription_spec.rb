require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it { should belong_to :widget }
  it { should belong_to :activist }
  it { should belong_to :community }

  it { should have_many :donations }

  let(:subscription) { Subscription.make!(card_data: { id: 'card_xpto_id'}) }

  before do
    PagarMe.api_key = 'some_gateway_api_key'
    allow_any_instance_of(Subscription).to receive(:subscribe_to_list)
    allow(subscription).to receive(:notify_activist)
  end

  describe 'handle_update' do
      let(:card_json) do
        ActiveSupport::JSON.decode('{
            "object": "card",
            "id": "card_cj428xxsx01dt3f6dvre6belx",
            "date_created": "2017-06-18T05:03:19.907Z",
            "date_updated": "2017-06-18T05:03:20.318Z",
            "brand": "visa",
            "holder_name": "Aardvark Silva",
            "first_digits": "401872",
            "last_digits": "8048",
            "country": "RU",
            "fingerprint": "TaApkY+9emV9",
            "customer": null,
            "valid": true,
            "expiration_date": "1122"}')
      end
      let(:customer_json) do
        ActiveSupport::JSON.decode('{
            "object": "customer",
            "document_number": "18152564000105",
            "document_type": "cnpj",
            "name": "nome do cliente",
            "email": "eee@email.com",
            "born_at": "1970-01-01T03:38:41.988Z",
            "gender": "M",
            "date_created": "2017-01-06T18:38:19.000Z",
            "id": 253591,
            "phones": [{
                "object": "phone",
                "ddi": "55",
                "ddd": "11",
                "number": "999887766",
                "id": 148590
            }],
            "addresses": [{
                "object": "address",
                "street": "rua qualquer",
                "complementary": "apto",
                "street_number": "13",
                "neighborhood": "pinheiros",
                "city": "sao paulo",
                "state": "SP",
                "zipcode": "05444040",
                "country": "Brasil",
                "id": 153809
            }]
            }')
      end
    before do
      stub_request(:post, "https://api.pagar.me/1/customers").with(body: hash_including({email: 'justwant@tochange.com'}))
        .to_return(status: 200, body: customer_json.to_json, headers: {})

      stub_request(:post, "https://api.pagar.me/1/customers").with(body: hash_including({email: 'invalid'}))
        .to_return(status: 400, body: {error: 'error_from_gateway'}.to_json, headers: {})

      stub_request(:post, "https://api.pagar.me/1/cards").with(body: hash_including({card_hash: 'foo_bar_card_hash'}))
        .to_return(status: 200, body: card_json.to_json, headers: {})

      stub_request(:post, "https://api.pagar.me/1/cards").with(body: hash_including({card_hash: 'invalid_hash'}))
        .to_return(status: 400, body: {error: 'error_from_gateway'}.to_json, headers: {})
    end
    context 'with new card' do
      let(:attrs) { { card_hash: 'foo_bar_card_hash' } }
      let(:invalid_card_attr) { { card_hash: 'invalid_hash' } }

      it 'should update card_data with new generated card' do
        subscription.handle_update(attrs)
        expect(subscription.card_data["id"]).to eq(card_json["id"])
      end

      it 'should be not valid when have some error' do
        result = subscription.handle_update(invalid_card_attr)
        expect(subscription.errors[:card_data].present?).to eq(true)
      end
    end

    context 'with new customer data' do

      it 'should update customer_data and gateway_customer_id with new customer' do
        result = subscription.handle_update({customer_data: { email: 'justwant@tochange.com' } })
        expect(subscription.customer_data).to eq(customer_json)
        expect(subscription.gateway_customer_id).to eq(customer_json["id"])
      end

      it 'should be not valid when have some error' do
        result = subscription.handle_update({customer_data: { email: 'invalid' } })
        expect(subscription.errors[:customer_data].present?).to eq(true)
      end
    end

    context 'with new amount' do
      it 'should change current amount on subscription' do
        subscription.handle_update({ amount: 3590 }) # 35,90
        expect(subscription.amount).to eq(3590)
      end
    end

    context 'with new schedule date' do
      it 'should update the schedule_next_charge_at' do
        new_date ||= 2.days.from_now
        expect(subscription.schedule_next_charge_at).to eq(nil)
        subscription.handle_update({ process_at: new_date.to_s })
        expect(subscription.schedule_next_charge_at.to_s).to eq(new_date.to_s)
        expect(subscription.next_transaction_charge_date.to_s).to eq(new_date.to_s)
      end
    end
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

  describe "reached_retry_limit?" do
    let(:created_at) { DateTime.now }
    before do
      Donation.make!(
        transaction_status: 'unpaid',
        created_at: created_at,
        local_subscription_id: subscription.id )
    end

    subject { subscription.reached_retry_limit? }

    context "when reached the retry limit" do
      let(:created_at) { 91.days.ago }
      before do
        subscription.transition_to(:unpaid)
        subscription.transitions.last.update_columns(created_at: created_at)
        subscription.reload
      end

      it { is_expected.to eq(true) }
    end

    context "when not reached the retry limit" do
      let(:created_at) { 69.days.ago }
      before do
        subscription.transition_to(:unpaid)
        subscription.transitions.last.update_columns(created_at: created_at)
        subscription.reload
      end

      it { is_expected.to eq(false) }
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
        it { is_expected.to eq({payment_method: 'boleto'}) }
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
    context "when subscription have schedule_next_charge_at defined" do
      let(:date) { 2.days.from_now }

      before do
        subscription.update_column(:schedule_next_charge_at, date)
      end
      subject { subscription.next_transaction_charge_date }
      it { is_expected.to eq(date) }
    end

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
            charge: true,
            customer: double(
              id: 12345
            )
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

        context 'when schedule_next_charge_at is defined' do
          let(:transaction) do
            double(
              {
                id: '1235',
                status: 'processing',
                payables: [{id: 'x'}, {id: 'y'}],
                card: { id: 'card_xpto_id'},
                charge: true,
                customer: double(
                  id: 12345
                )
              })
          end
          before do
            expect(PagarMe::Transaction).to receive(:new).with(pagarme_attributes).and_return(transaction)
            subscription.update_column(:schedule_next_charge_at, 2.days.ago)
          end

          it 'should clean schedule_next_charge_at' do
            expect(subscription.schedule_next_charge_at.nil?).to eq(false)
            charged = subject
            subscription.reload
            expect(subscription.schedule_next_charge_at).to eq(nil)
          end
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
                charge: true,
                customer: double(
                  id: 12345
                )
              })
          end
          before do
            expect(PagarMe::Transaction).to receive(:new).with(pagarme_attributes).and_return(transaction)
          end

          it 'should charge and update generated donation' do
            expect(subscription).to receive(:notify_activist).with(:slip_subscription)
            expect(subscription).to receive(:transition_to).with(:waiting_payment, anything)
            expect(SubscriptionWorker).not_to receive(:perform_at).with(anything, subscription.id).and_call_original
            charged = subject
            expect(charged.transaction_id).to eq("1235")
            expect(charged.cached_community_id).to eq(subscription.community.id)
            expect(charged.transaction_status).to eq('waiting_payment')
            expect(subscription.gateway_customer_id).to eq(12345)
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
                charge: true,
                customer: double(
                  id: 12345
                )
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
            expect(charged.cached_community_id).to eq(subscription.community.id)
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
            expect(charged.cached_community_id).to eq(subscription.community.id)
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
                charge: true,
                customer: double(
                  id: 12345
                )
              })
          end
          before do
            expect(PagarMe::Transaction).to receive(:new).with(pagarme_attributes).and_return(transaction)
          end
          it 'should charge and update generated donation' do
            expect(subscription).to receive(:notify_activist).with(:unpaid_subscription)
            expect(subscription).to receive(:transition_to).with(:unpaid, anything).and_call_original
            expect(SubscriptionWorker).to receive(:perform_at).with(anything, subscription.id, kind_of(Numeric))
            charged = subject
            expect(charged.transaction_id).to eq("1235")
            expect(charged.cached_community_id).to eq(subscription.community.id)
            expect(charged.transaction_status).to eq('refused')
            expect(subscription.current_state).to eq('unpaid')
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
                charge: true,
                customer: double(
                  id: 12345
                )
              })
          end
          before do
            subscription.transition_to(:unpaid)
            expect(PagarMe::Transaction).to receive(:new).with(pagarme_attributes).and_return(transaction)
          end
          it 'should charge and update generated donation' do
            expect(subscription).to receive(:notify_activist).with(:unpaid_subscription)
            expect(subscription).to receive(:transition_to).with(:unpaid, anything).and_call_original
            expect(SubscriptionWorker).to receive(:perform_at).with(anything, subscription.id, kind_of(Numeric))
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

  describe '#mailchimp_add_active_donators' do
    let(:widget) { spy :widget }

    before do 
      allow(widget).to receive(:id).and_return(12)
      allow(subscription).to receive(:widget).and_return(widget)
    end

    context 'active on mailchimp\'s list' do
      before do
        allow(subscription).to receive(:status_on_list).and_return :subscribed
        allow(subscription).to receive(:subscribe_to_segment)
      end
      it "should create donations segments, if needed" do 
        subscription.mailchimp_add_active_donators
        expect(subscription).to have_received(:subscribe_to_segment).once
      end
    end

    context 'inactive on mailchimp\'s list' do
      before do
        allow(subscription).to receive(:status_on_list).and_return :unsubscribed
        allow(subscription).to receive(:subscribe_to_segment)
      end
      it "should create donations segments, if needed" do 
        subscription.mailchimp_add_active_donators
        expect(subscription).not_to have_received(:subscribe_to_segment)
      end
    end
  end

  describe '#mailchimp_remove_from_active_donators' do
    context 'if not on mailchimp' do
      before do
        allow(subscription).to receive(:status_on_list).and_return :not_registred
      end

      it "should raise an error - we expect it already there" do 
        expect{subscription.mailchimp_remove_from_active_donators}.to raise_error(StandardError)
      end
    end

    context 'active on mailchimp\'s list' do
      before do
        allow(subscription).to receive(:status_on_list).and_return :subscribed
        allow(subscription).to receive(:subscribe_to_segment)
        allow(subscription).to receive(:unsubscribe_from_segment)
        subscription.mailchimp_remove_from_active_donators
      end
    
      it { expect(subscription).to have_received(:subscribe_to_segment).once }

      it { expect(subscription).to have_received(:unsubscribe_from_segment).once }
    end

    context 'inactive on mailchimp\'s list' do
      before do
        allow(subscription).to receive(:status_on_list).and_return :unsubscribed
        allow(subscription).to receive(:subscribe_to_segment)
        allow(subscription).to receive(:unsubscribe_from_segment)
        subscription.mailchimp_remove_from_active_donators
      end
      it { expect(subscription).not_to have_received(:subscribe_to_segment) }

      it { expect(subscription).not_to have_received(:unsubscribe_from_segment) }
    end
  end
end
