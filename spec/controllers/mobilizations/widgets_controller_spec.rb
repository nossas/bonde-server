require 'rails_helper'

RSpec.describe Mobilizations::WidgetsController, type: :controller do
  before do
    @widget1 = Widget.make!
    @widget2 = Widget.make!
  end

  describe "GET #index" do
    it "should return widgets by mobilization" do
      get :index, mobilization_id: @widget1.block.mobilization_id

      expect(response.body).to include(@widget1.to_json)
      expect(response.body).to_not include(@widget2.to_json)
    end
  end

  describe "PUT #update" do
    it "should update widget" do
      put :update, {
        mobilization_id: @widget1.block.mobilization_id,
        id: @widget1.id,
        widget: {
          settings: {
            content: "Widget new content"
          }
        }
      }

      expect(response.body).to include("Widget new content")
    end
  end
end
