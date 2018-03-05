require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do

  describe 'GET show' do
    let(:subscription) { Subscription.make! }

    before do
      get :show, format: :json, id: subscription.id, token: subscription_token
    end

    context 'when have subscription token' do
      let(:subscription_token) { subscription.token }
      it 'should render serialized subscription as json' do
        json_response = ActiveSupport::JSON.decode(response.body)
        expect(response.status).to eq(200)
        expect(json_response["id"]).to eq(subscription.id)
      end
    end

    context 'when not have subscription token' do
      let(:subscription_token) { nil }
      it 'should not found subscription' do
        json_response = ActiveSupport::JSON.decode(response.body)
        expect(response.status).to eq(404)
        expect(json_response["id"]).to eq(nil)
      end
    end
  end

  describe 'POST recharge' do
    let(:subscription) { Subscription.make! }
    let(:subscription_token) { subscription.token }
    let!(:process_at) { 4.days.from_now }
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
      PagarMe.api_key = 'some_gateway_api_key'

      stub_request(:post, "https://api.pagar.me/1/customers").with(body: hash_including({email: 'justwant@tochange.com'}))
        .to_return(status: 200, body: customer_json.to_json, headers: {})

      stub_request(:post, "https://api.pagar.me/1/cards").with(body: hash_including({card_hash: 'foo_bar_card_hash'}))
        .to_return(status: 200, body: card_json.to_json, headers: {})
      stub_request(:post, "https://api.pagar.me/1/cards").with(body: hash_including({card_hash: 'invalid_hash'}))
        .to_return(status: 400, body: {error: 'error_from_gateway'}.to_json, headers: {})
    end

    context 'change customer data' do
      before do
        post :recharge, format: :json, id: subscription.id, token: subscription_token, customer_data: { email: 'justwant@tochange.com' }
      end

      it 'should change card_data on subscription' do
        subscription.reload
        expect(subscription.customer_data['id']).to eq(customer_json['id'])
        expect(subscription.gateway_customer_id).to eq(customer_json['id'])
        json_response = ActiveSupport::JSON.decode(response.body)
        expect(response.status).to eq(200)
        expect(json_response["id"]).to eq(subscription.id)
      end
    end

    context 'change card data' do
      before do
        post :recharge, format: :json, id: subscription.id, token: subscription_token, card_hash: 'foo_bar_card_hash'
      end

      it 'should change card_data on subscription' do
        subscription.reload
        expect(subscription.card_data['id']).to eq(card_json['id'])
        json_response = ActiveSupport::JSON.decode(response.body)
        expect(response.status).to eq(200)
        expect(json_response["id"]).to eq(subscription.id)
      end
    end

    context 'card data with error' do
      before do
        post :recharge, format: :json, id: subscription.id, token: subscription_token, card_hash: 'invalid_hash'
      end

      it 'should retun errors on request' do
        subscription.reload
        json_response = ActiveSupport::JSON.decode(response.body)
        expect(response.status).to eq(400)
      end
    end

    context 'schedule a new date to charge' do
      before do
        post :recharge, format: :json, id: subscription.id, token: subscription_token, process_at: process_at
      end

      it 'should fill schedule_next_charge_at on subscription' do
        subscription.reload
        expect(subscription.schedule_next_charge_at).to eq(process_at)
        json_response = ActiveSupport::JSON.decode(response.body)
        expect(response.status).to eq(200)
        expect(json_response["id"]).to eq(subscription.id)
      end
    end

    context 'when not have subscription token' do
      before do
        post :recharge, format: :json, id: subscription.id, token: subscription_token
      end
      let(:subscription_token) { nil }
      it 'should not found subscription' do
        json_response = ActiveSupport::JSON.decode(response.body)
        expect(response.status).to eq(404)
        expect(json_response["id"]).to eq(nil)
      end
    end
  end

  describe 'DELETE destroy' do
    let(:subscription) { Subscription.make! }
    let(:subscription_token) { subscription.token }

    context 'when subscription is not canceled' do
      before do
        allow_any_instance_of(Subscription).to receive(:notify_activist)
        delete :destroy, format: :json, id: subscription.id, token: subscription_token
      end
      it 'should cancel subscription' do
        subscription.reload
        json_response = ActiveSupport::JSON.decode(response.body)
        expect(response.status).to eq(200)
        expect(json_response["id"]).to eq(subscription.id)
        expect(subscription.status).to eq('canceled')
      end
    end

    context 'when not have subscription token' do
      before do
        delete :destroy, format: :json, id: subscription.id, token: subscription_token
      end

      let(:subscription_token) { nil }
      it 'should not found subscription' do
        json_response = ActiveSupport::JSON.decode(response.body)
        expect(response.status).to eq(404)
        expect(json_response["id"]).to eq(nil)
      end
    end
  end

end
