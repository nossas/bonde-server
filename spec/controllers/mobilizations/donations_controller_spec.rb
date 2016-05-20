require 'rails_helper'

RSpec.describe Mobilizations::DonationsController, type: :controller do
  before do
    allow_any_instance_of(Donation).to receive(:capture_transaction)

    @user = User.make!
    stub_current_user(@user)
    @widget = Widget.make! kind: 'donation'
  end

  describe "GET #index" do
    it "should return donations by widget" do
      mobilization = Mobilization.make!
      widget1 = Widget.make! mobilization: mobilization
      widget2 = Widget.make! mobilization: mobilization
      donation1 = Donation.make! widget: widget1
      donation2 = Donation.make! widget: widget2

      get :index, mobilization_id: mobilization.id, widget_id: widget1.id

      expect(response.body).to include(donation1.to_json)
      expect(response.body).to_not include(donation2.to_json)
    end
  end
end
