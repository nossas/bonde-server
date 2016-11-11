require 'rails_helper'

RSpec.describe Mobilizations::WidgetsController, type: :controller do
  before do
    @widget1 = Widget.make!
    @widget2 = Widget.make!
    @user = User.make! admin: false
    @admin = User.make! admin: true
    stub_current_user(@user)
  end

  describe "GET #index" do
    context "on valid call" do
      before do
        get :index, mobilization_id: @widget1.block.mobilization_id
      end

      it "should return widgets by mobilization" do
        expect(response.body).to include(@widget1.to_json)
        expect(response.body).to_not include(@widget2.to_json)
      end

      it "should return a 200 status" do
        expect(response.status).to be 200
      end
    end
  end

  xdescribe "PUT #update" do
    it "should update widget when current user is admin" do
      stub_current_user(@admin)
      put :update, update_widget_1_params

      expect(response.body).to include("Widget new content")
    end

    it "should update widget when current user is the mobilization's owner" do
      stub_current_user(@widget1.mobilization.user)
      put :update, update_widget_1_params

      expect(response.body).to include("Widget new content")
    end

    it "should return 401 if user is not an admin or mobilization's owner" do
      stub_current_user(User.make!)
      put :update, update_widget_1_params

      expect(response).to be_unauthorized
    end
  end
end

def update_widget_1_params
  {
    mobilization_id: @widget1.block.mobilization_id,
    id: @widget1.id,
    widget: {
      settings: {
        content: "Widget new content"
      }
    }
  }
end
