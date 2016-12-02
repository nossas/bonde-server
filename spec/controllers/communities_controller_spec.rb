require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  describe "GET #index" do
    it "should return all organizations" do
      3.times { Organization.make! }
      get :index
      expect(response.body).to include(Organization.all.to_json)
    end
  end
end
