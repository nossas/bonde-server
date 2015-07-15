require 'rails_helper'

RSpec.describe Mobilizations::WidgetsController, type: :controller do
  describe "GET #index" do
    it "should return widgets by mobilization" do
      widget1 = Widget.make!
      widget2 = Widget.make!

      get :index, mobilization_id: widget1.block.mobilization_id

      expect(response.body).to include(widget1.to_json)
      expect(response.body).to_not include(widget2.to_json)
    end
  end
end
