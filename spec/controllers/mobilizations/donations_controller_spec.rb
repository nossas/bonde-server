require 'rails_helper'

RSpec.describe Mobilizations::DonationsController, type: :controller do
  before do
    @user = User.make!
    stub_current_user(@user)
  end

  describe "POST #create" do
    it "should create with JSON format and parameters" do
      donation = Donation.make!
      post(
        :create,
        mobilization_id: donation.widget.mobilization.id,
        format: :json,
        donation: {
          widget_id: donation.widget.id
        }
      )

      last_donation = Donation.last
      expect(response.status).to eq 200
      expect(response.body).to include(last_donation.to_json)
    end
  end
end
