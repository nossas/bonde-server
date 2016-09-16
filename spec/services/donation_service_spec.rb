require "rails_helper"

RSpec.describe DonationService do
  let(:donation) { Donation.make! gateway_data: nil}
  describe '#update_from_gateway' do
    let(:transaction) do
      double(payables: [], gateway_data: {id: 'foo'})
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
end
