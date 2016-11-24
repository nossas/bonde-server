require 'rails_helper'

RSpec.describe BlocksController, type: :controller do
  before do
    @user = User.make!
    stub_current_user(@user)
  end

  describe "GET #index" do
    before do
      mobilization = Mobilization.make!
      @block = Block.make! mobilization: mobilization

      get :index, custom_domain: mobilization.custom_domain
    end

    it "should return blocks by mobilization's custom domain" do
      expect(response.body).to include(@block.to_json)
    end

    it "should return a 200 status" do
      expect(response.status).to be 200
    end
  end
end
