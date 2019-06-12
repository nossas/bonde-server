require 'rails_helper'

RSpec.describe ConvertDonationsController, type: :controller do
  let(:widget) { Widget.make!(kind: 'donation')}
  let(:donation) { Donation.make!(amount: 1000, widget: widget) }

  before do
    allow(DonationService).to receive(:process_subscription).and_return(true)
  end

  describe 'GET /replay' do
    context 'when user_email and widget_id has match' do
      before do
        get :replay, user_email: donation.activist.email, widget_id: donation.widget_id
      end

      xit 'should replay the donation with new amout' do
        expect(response.status).to eq(200)
        expect(ActiveSupport::JSON.decode(response.body)['converted_from']).to eq(donation.id)
        expect(ActiveSupport::JSON.decode(response.body)['amount']).to eq(1000)
      end
    end

    context 'should change value when passing amount' do
      before do
        get :replay, amount: 2000, user_email: donation.activist.email, widget_id: donation.widget_id
      end

      xit 'should convert using new amount' do
        expect(response.status).to eq(200)
        expect(ActiveSupport::JSON.decode(response.body)['converted_from']).to eq(donation.id)
        expect(ActiveSupport::JSON.decode(response.body)['amount']).to eq(2000)
      end
    end
  end

  describe 'GET /convert' do
    context 'when donation_id has match' do
      before do
        get :convert, donation_id: donation.id
      end

      it 'should convert the donation to a subcription' do
        expect(response.status).to eq(200)
        expect(ActiveSupport::JSON.decode(response.body)['subscription']).to eq(true)
        expect(ActiveSupport::JSON.decode(response.body)['amount']).to eq(1000)
      end
    end

    context 'should change value when passing amount' do
      before do
        get :convert, amount: 2000, donation_id: donation.id
      end

      it 'should convert using new amount' do
        expect(response.status).to eq(200)
        expect(ActiveSupport::JSON.decode(response.body)['subscription']).to eq(true)
        expect(ActiveSupport::JSON.decode(response.body)['amount']).to eq(2000)
      end
    end

    context 'when user_email and widget_id not match' do
      it 'should raise an error' do
        expect {
          get :convert, user_email: donation.activist.email, widget_id: 12313
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
