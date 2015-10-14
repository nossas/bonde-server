require 'rails_helper'

RSpec.describe BlocksController, type: :controller do
  before do
    @user = User.make!
    stub_current_user(@user)
  end

  describe "GET #index" do
    it "should return blocks by mobilization's custom domain" do
      mobilization = Mobilization.make!
      block = Block.make! mobilization: mobilization

      get :index, custom_domain: mobilization.custom_domain

      expect(response.body).to include(block.to_json)
    end

    it "should return blocks by mobilization's slug" do
      mobilization = Mobilization.make!
      block = Block.make! mobilization: mobilization

      get :index, slug: mobilization.slug

      expect(response.body).to include(block.to_json)
    end
  end
end
