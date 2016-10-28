require 'rails_helper'

RSpec.describe MobilizationsController, type: :controller do
  before do
    @user1 = User.make!
    @user2 = User.make!
    stub_current_user(@user1)
  end

  describe "GET #index" do
    before do
      @mob1 = Mobilization.make! user: @user1, custom_domain: "foobar", slug: "1-foo"
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

    it "should return mobilizations by custom_domain" do
      get :index, custom_domain: "foobar"

      expect(response.body).to include(@mob1.name)
      expect(response.body).to_not include(@mob2.name)
    end

    it "should return mobilizations by slug" do
      get :index, slug: "1-foo"

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
    context "single creation" do
      it "should create with JSON format" do
        organization = Organization.make!
        expect(Mobilization.count).to eq(0)

        post :create, format: :json, mobilization: {
          name: 'Foo',
          goal: 'Bar',
          organization_id: organization.id
        }

        expect(Mobilization.count).to eq(1)
        expect(response.body).to include(Mobilization.first.to_json)
      end
    end

    context "creation from an existing template" do
      before do
        @template = TemplateMobilization.make!
        block = TemplateBlock.make! template_mobilization:@template
        widget = TemplateWidget.make! template_block:block
      end

      it "should return a 200 status if created" do
        post :create, { template_mobilization_id: @template.id }

        expect(response.status).to eq(200)
      end

      it "should create from a template" do
        post :create, { template_mobilization_id: @template.id }

        expect(Mobilization.count).to eq(1)
        expect(response.body).to include(@template.name)
      end

      it 'should increment the uses_number for each use' do
        post :create, { template_mobilization_id: @template.id }

        newTemplate = TemplateMobilization.find @template.id
        expect(newTemplate.uses_number).to eq((@template.uses_number||0) + 1)
      end
    end

    context "creation from an inexisting template" do
      it "should return a 404 status" do
        post :create, { template_mobilization_id: 0 }

        expect(response.status).to eq(404)
      end
    end
  end
end
