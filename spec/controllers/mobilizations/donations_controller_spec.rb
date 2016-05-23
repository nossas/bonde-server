require 'rails_helper'

RSpec.describe Mobilizations::DonationsController, type: :controller do
  before do
    allow_any_instance_of(Donation).to receive(:create_transaction)

    @user = User.make!
    stub_current_user(@user)
    @widget = Widget.make! kind: 'donation'
  end

  describe "POST #create" do
    it "should create with JSON format and parameters" do
      expect {
        post(:create, mobilization_id: @widget.mobilization.id, format: :json, donation: donation_params)
      }.to change { Donation.count }.by 1
    end

    it "should include customer data" do
      post(:create, mobilization_id: @widget.mobilization.id, format: :json, donation: donation_params)

      donation = Donation.last
      expect(donation.widget_id).to eq @widget.id
      expect(donation.customer["name"]).to eq customer_params[:name]
      expect(donation.customer["phone"]).not_to be_empty
      expect(donation.customer["address"]).not_to be_empty
    end
  end
end

def donation_params
  { widget_id: @widget.id, payment_method: "boleto", amount: "2000", customer: customer_params }
end

def customer_params
  {
    name: "Customer",
    email: "someemail@mail.com",
    document_number: "0000000000",
    phone: { "ddd" => "00", "number" => "00000000"},
    address: { "zipcode" => "0000000", "street" => "Street", "street_number" => "000", "complementary" => "", "neighborhood" => "Neighborhood", "city" => "City", "state" => "AA"}
  }
end
