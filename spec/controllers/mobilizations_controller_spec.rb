require 'rails_helper'

RSpec.describe MobilizationsController, type: :controller do
  before do
    stub_request(:delete, "https://api.heroku.com/apps//domains/mymobilization").
       with(:headers => {'Accept'=>'application/vnd.heroku+json; version=3', 'Authorization'=>'Bearer ', 'Host'=>'api.heroku.com:443', 'User-Agent'=>'excon/0.54.0'}).
       to_return(:status => 200, :body => "", :headers => {})

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

  describe 'PATCH #update' do
    before do
      @mobilization = Mobilization.make! user: @user1
    end
  
    context 'update an existing Mobilization' do
      subject {
        Mobilization.make! user:@user1
      }

      it 'should change data in database' do
        patch :update, {format: :json, mobilization: {name: 'super-hiper-marevelous mobilization'}, id: subject.id}

        expect((Mobilization.find subject.id).name).to eq('super-hiper-marevelous mobilization')
      end

      it 'should return an 200' do
        patch :update, {format: :json, mobilization: {name: 'super-hiper-marevelous mobilization'}, id: subject.id}

        expect(response.status).to eq(200)
      end
    end

  end
  describe 'PUT #update' do
    before do
      @mobilization = Mobilization.make! user: @user1
    end

    context "update an existing Mobilization from an existing template" do
      before do
        @template = TemplateMobilization.make!
        block = TemplateBlock.make! template_mobilization:@template
        TemplateWidget.make! template_block:block
        
        stub_request(:delete, "https://api.heroku.com/apps//domains/mymobilization").
          with(:headers => {'Accept'=>'application/vnd.heroku+json; version=3', 'Authorization'=>'Bearer ', 'Host'=>'api.heroku.com:443', 'User-Agent'=>'excon/0.45.4'}).
          to_return(:status => 200, :body => "", :headers => {})


        put :update, { template_mobilization_id: @template.id, id: @mobilization.id }
      end

      it "should return a 200 status if created" do
        expect(response.status).to eq(200)
      end

      it "should update data from a template" do
        mob = Mobilization.find @mobilization.id
        expect(mob.header_font).to eq(@template.header_font)
      end

      it "should not update name from a mobilization" do
        mob = Mobilization.find @mobilization.id
        expect(mob.name).to eq(@mobilization.name)
      end

      it "should not update goal from a mobilization" do
        mob = Mobilization.find @mobilization.id
        expect(mob.goal).to eq(@mobilization.goal)
      end

      it "should return the new data" do
        expect(response.body).to include(@template.header_font)
      end

      it 'should increment the uses_number for each use' do
        newTemplate = TemplateMobilization.find @template.id
        expect(newTemplate.uses_number).to eq((@template.uses_number||0) + 1)
      end
    end

    context "update from an inexisting template" do
      it "should return a 404 status" do
        put :update, { template_mobilization_id: 0, id: @mobilization.id }

        expect(response.status).to eq(404)
      end
    end
  end
  

  describe "POST #create" do
    context "single creation" do
      it "should create with JSON format" do
        community = Community.make!
        expect(Mobilization.count).to eq(0)

        post :create, format: :json, mobilization: {
          name: 'Foo',
          goal: 'Bar',
          community_id: community.id
        }

        expect(Mobilization.count).to eq(1)
        expect(response.body).to include(Mobilization.first.to_json)
      end
    end
  end
end
