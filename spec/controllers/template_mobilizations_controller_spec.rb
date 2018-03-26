require 'rails_helper'

RSpec.describe TemplateMobilizationsController, type: :controller do
  before do
    @user1 = User.make!
    @community = Community.make!
    stub_current_user(@user1)
  end

  context "GET #index" do
    before do
      @template1 = TemplateMobilization.make! user: @user1, community: @community
      @template2 = TemplateMobilization.make! user: @user1, community: @community
      @template3 = TemplateMobilization.make! user: @user1
  	  @template4 = TemplateMobilization.make! global: true
    end
    describe "user templates" do
      it "should return only company templates" do
        get :index, community_id: @community.id

        expect(response.body).to include(@template1.name)
        expect(response.body).to include(@template2.name)
        expect(response.body).to_not include(@template3.name)
        expect(response.body).to_not include(@template4.name)
      end
    end

    describe "with global option" do
      it "should return only current user templates" do
        get :index
        expect(response.body).to include(@template2.name)
        expect(response.body).to include(@template1.name)
        expect(response.body).to include(@template3.name)
        expect(response.body).to_not include(@template4.name)
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

        expect(response).to be_ok
      end
    end

    describe "inexisting template" do
      it "should return a 404 status" do
        delete :destroy, id: 0

        expect(response).to be_not_found
      end
    end
  end

  context 'POST #create' do 
    describe 'create a template from existing mobilization' do
      let(:mobilization) { Mobilization.make! user:@user1 }
      let(:block1) { Block.make! mobilization: mobilization }
      let(:block2) { Block.make! mobilization: mobilization }
      let(:widget1_1) {Widget.make! block:block1}
      let(:widget2_1) {Widget.make! block:block2}
      let(:widget2_2) {Widget.make! block:block2}
      let(:block_sequence) { [] }      
      let(:widget_sequence) { [] }

      before do
        block_sequence << block1 << block2
        widget_sequence << widget1_1 << widget2_1 << widget2_2
        @count_mobilization = TemplateMobilization.count
        @count_blocks = TemplateBlock.count
        @count_widgets = TemplateWidget.count

        post :create, {mobilization_id: mobilization.id, goal: 'World conquest', name: 'Pinky & Brain\'s world conquest' }
      end

      it 'should return 200 status response' do
        expect(response).to be_ok
      end

      it 'should create one TemplateMobilization' do
        expect(TemplateMobilization.count).to eq(@count_mobilization + 1)        
      end

      it 'should create two blocks' do
        expect(TemplateBlock.count).to eq(@count_blocks + 2)        
      end

      it 'should create three widgets' do
        expect(TemplateWidget.count).to eq(@count_widgets + 3)        
      end

      it 'should save use the name parameter as template\'s name' do
        expect(TemplateMobilization.last.name).to eq('Pinky & Brain\'s world conquest')        
      end

      it 'should save use the goal parameter as template\'s goal' do
        expect(TemplateMobilization.last.goal).to eq('World conquest')        
      end

      it 'should return the template created data' do
        expect(response.body).to include(mobilization.slug)
      end

      it 'should create all block nested data' do
        data = JSON.parse response.body
        expect(TemplateBlock.where("template_mobilization_id = #{data['id']}").count).to eq(2) 
      end

      it 'should create all nested widget data' do
        data = JSON.parse response.body
        expect( TemplateWidget.joins(:template_block).where("template_blocks.template_mobilization_id = #{data['id']}").count).to eq(3) 
      end

      it 'should save template_blocks on the same order than blocks' do
        blocks = TemplateMobilization.last.template_blocks.order(:id).map{|b| b.name}

        expect(block_sequence.map{|b| b.name}).to eq(blocks)
      end

      it 'should save template_widgets on the same order than widgets' do
        widgets = TemplateMobilization.last.
            template_blocks.order(:id).map{|b| b.template_widgets.order(:id)}.
            flatten.map{|w| w.settings}


        expect(widget_sequence.map{|w| w.settings}).to eq(widgets)
      end
    end

    describe "deal with inexisting mobilization" do
      it 'should return an 404' do
        post :create, {mobilization_id: 0, goal: 'World conquest', name: 'Pinky & Brain\'s world conquest' }

        expect(response).to be_not_found
      end
    end

    describe "deal with missing parameters" do

      it 'should return 400 (Bad Request) if there\'s missing the mobilization id param' do
        post :create , {goal: 'World conquest', name: 'Pinky & Brain\'s world conquest' }

        expect(response.status).to eq(400)
      end

      it 'should return the missing field name (mobilization id) if there\'s missing the mobilization id param' do
        post :create , {goal: 'World conquest', name: 'Pinky & Brain\'s world conquest' }

        expect(response.body).to include('mobilization_id')
      end

      it 'should return the missing fields names if there are more the one param missing' do
        post :create , {name: 'Pinky & Brain\'s world conquest' }

        expect(response.body).to include('mobilization_id')
        expect(response.body).to include('goal')
      end

      it 'should return 400 (Bad Request) if there\'s missing the goal param' do
        post :create , {mobilization_id: 1, name: 'Pinky & Brain\'s world conquest' }

        expect(response.status).to eq(400)
      end

      it 'should return 400 (Bad Request) if there\'s missing the name param' do
        post :create , {mobilization_id: 1, goal: 'World conquest'}

        expect(response.status).to eq(400)
      end
    end
  end
end
