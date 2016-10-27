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

  context "DELETE #destroy" do 
    describe "existing template" do
      before do
        @template = TemplateMobilization.make! user:@user1
        @block = TemplateBlock.make! template_mobilization:@template
        @widget = TemplateWidget.make! template_block:@block
        @template.template_blocks << @block
        @block.template_widgets << @widget
      end
  
      it "should delete the template_mobilization" do
        delete :destroy, id: @template.id
  
        expect(TemplateMobilization.exists? @template.id).to be false
      end
  
      it "should delete the blocks related to the template_mobilization" do
        delete :destroy, id: @template.id
  
        expect(TemplateBlock.exists? @block.id).to be false
      end
  
      it "should delete the widgets related to the template_mobilization" do
        delete :destroy, id: @template.id
  
        expect(TemplateWidget.exists? @widget.id).to be false
      end

      it "should return a 200 status" do
        delete :destroy, id: @template.id

        expect(response.status).to eq(200)
      end
    end

    describe "inexisting template" do
      it "should return a 404 status" do
        delete :destroy, id: 0

        expect(response.status).to eq(404)
      end
    end
  end

  context "POST #create" do 
    describe "create a template from existing mobilization" do
      before do
        @mobilization = Mobilization.make! user:@user1
        block = Block.make! mobilization: @mobilization
        Widget.make! block:block
        block = Block.make! mobilization: @mobilization
        Widget.make! block:block
        Widget.make! block:block
      end

      it "should return 200 status response" do
        post :create, {mobilization_id: @mobilization.id}

        expect(response.status).to eq(200)
      end

      it "should return the template created data" do
        post :create, {mobilization_id: @mobilization.id}

        expect(response.body).to include(@mobilization.name)
      end

      it "should create all block nested data" do
        post :create, {mobilization_id: @mobilization.id}

        data = JSON.parse response.body
        expect(TemplateBlock.where("template_mobilization_id = #{data['id']}").count).to eq(2) 
      end

      it "should create all nested widget data" do
        post :create, {mobilization_id: @mobilization.id}

        data = JSON.parse response.body
        expect( TemplateWidget.joins(:template_block).where("template_blocks.template_mobilization_id = #{data['id']}").count).to eq(3) 
      end

    end

    describe "deal with inexisting mobilization" do
      it "should return an 404" do
        post :create, {mobilization_id: 0}

        expect(response.status).to eq(404)
      end
    end
  end
end
