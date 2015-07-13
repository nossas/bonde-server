require 'rails_helper'

RSpec.describe MobilizationsController, type: :controller do
  describe "GET #index" do
    before do
      @user1 = User.create password: "12345678", uid: "nicolas1@trashmail.com", provider: "email", email: "nicolas1@trashmail.com"
      @user2 = User.create password: "12345678", uid: "nicolas2@trashmail.com", provider: "email", email: "nicolas2@trashmail.com"
      @mob1 = Mobilization.create name: "My Mobilization 1", user: @user1
      @mob2 = Mobilization.create name: "My Mobilization 2", user: @user2
    end

    it "should return all mobilizations" do
      get :index

      expect(response.body).to include(@mob1.name)
      expect(response.body).to include(@mob2.name)
    end

    it "should return mobilizations by user" do
      get :index, user_id: @user1.id
      
      expect(response.body).to include(@mob1.name)
      expect(response.body).to_not include(@mob2.name)
    end
  end
end
