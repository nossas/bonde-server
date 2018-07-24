require "rails_helper"

RSpec.describe DonationService do
  let(:donation) { Donation.make! gateway_data: nil}
  describe '#update_from_gateway' do
    let(:transaction) do
      double(payables: [], gateway_data: {id: 'foo'}, status: '')
    end

    before do
      expect(PagarMe::Transaction).to receive(:find_by_id).and_return(transaction)
      expect(donation).to receive(:update_attributes).and_call_original
    end

    it "should update gateway data on donation" do
      DonationService.update_from_gateway(donation)
      expect(donation.gateway_data).not_to be_nil
    end
  end

  describe "#create_transaction" do
    let(:donation) { Donation.make! gateway_data: nil, credit_card: "123124241"}
    let(:activist)  { Activist.make }
    let(:address) { Address.make! activist: activist }
    let(:transaction) do
      double(id: 123132, payables: [], gateway_data: { id: 'foo' }, status: 'paid')
    end

    before do
      create(:notification_template, label: 'paid_donation')
      expect(PagarMe::Transaction).to receive(:new).and_return(transaction)

      expect(PagarMe::Transaction).to receive(:find_by_id).and_return(transaction)
      expect(DonationService).to receive(:find_or_create_card).and_return(donation)
      allow(transaction).to receive("customer=")
      allow(transaction).to receive(:charge)
    end

    it 'should create new transaction and return status' do
      DonationService.create_transaction(donation, address)

      expect(donation.transaction_id).not_to be_nil
      expect(donation.transaction_id.to_i).to eq(transaction.id)
      expect(donation.transaction_status).to eq('paid')
    end
  end
end
