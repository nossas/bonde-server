require 'rails_helper'

RSpec.describe MobilizationsController, type: :controller do
  before do
    @user1 = User.make!
    @user2 = User.make!
    stub_current_user(@user1)
  end

  describe "GET #index" do
    before do
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

    it "should return mobilizations by id" do
      get :index, ids: [@mob1.id]

      expect(response.body).to include(@mob1.name)
      expect(response.body).to_not include(@mob2.name)
    end
  end

  describe "POST #create" do
    it "should create with JSON format" do
      expect(Mobilization.count).to eq(0)
      post :create, format: :json, mobilization: {name: 'Foo', goal: 'Bar'}
      expect(Mobilization.count).to eq(1)
      expect(response.body).to include(Mobilization.first.to_json)
    end
  end
end
