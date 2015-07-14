require 'rails_helper'

RSpec.describe MobilizationsController, type: :controller do
  describe "GET #index" do
    before do
      @user1 = User.make!
      @user2 = User.make!
      @mob1 = Mobilization.make! user: @user1
      @mob2 = Mobilization.make! user: @user2
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
