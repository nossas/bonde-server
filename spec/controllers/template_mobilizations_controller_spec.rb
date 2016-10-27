require 'rails_helper'

RSpec.describe TemplateMobilizationsController, type: :controller do
  before do
    @user1 = User.make!
    stub_current_user(@user1)
  end

  context "GET #index" do 
    before do
  	  @template1 = TemplateMobilization.make! user:@user1
  	  @template2 = TemplateMobilization.make! user:@user1, global: true
  	  @template3 = TemplateMobilization.make!
  	  @template4 = TemplateMobilization.make! global: true
    end
    describe "user templates" do
      it "should return only user's templates" do
        get :index

        expect(response.body).to include(@template1.name)
        expect(response.body).to include(@template2.name)
        expect(response.body).to_not include(@template3.name)
        expect(response.body).to_not include(@template4.name)
      end
    end

    describe "with global option" do
      it "should return only global templates" do
        get :index, global: 'true'
        expect(response.body).to include(@template2.name)
        expect(response.body).to include(@template4.name)
        expect(response.body).to_not include(@template1.name)
        expect(response.body).to_not include(@template3.name)
      end
    end
  end
end
