require 'rails_helper'

RSpec.describe CommunitiesController, type: :controller do
  describe "GET #index" do
    it "should return all organizations" do
      3.times { Community.make! }
      get :index
      expect(response.body).to include(Community.all.to_json)
    end
  end
end
