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

  describe 'PATCH #update' do
    context 'update an existing Mobilization' do
      subject {
        Mobilization.make! user:@user1
      }

      let(:mob) { Mobilization.find subject.id }

      it 'should change data in database' do
        patch :update, {format: :json, mobilization: {name: 'super-hiper-marevelous mobilization', tag_list: "corrupto, político"}, id: subject.id}

        expect(mob.name).to eq('super-hiper-marevelous mobilization')
        expect(mob.tag_list).to include('corrupto')
        expect(mob.tag_list).to include('politico')
      end

      it 'should return an 200' do
        patch :update, {format: :json, mobilization: {name: 'super-hiper-marevelous mobilization'}, id: subject.id}

        expect(response.status).to eq(200)
      end
    end

  end
  describe 'PUT #update' do
    let(:template) { TemplateMobilization.make! }
    let(:mobilization) { Mobilization.make! user: @user1 }
    let(:saved_mobilization) { Mobilization.find mobilization.id }

    context "update an existing Mobilization from an existing template" do
      let(:template_block_1) { TemplateBlock.make! template_mobilization:template }
      let(:tempalte_widget_1_1) { TemplateWidget.make! template_block:template_block_1 }
      let(:tempalte_widget_1_2) { TemplateWidget.make! template_block:template_block_1 }
      let(:template_block_2) { TemplateBlock.make! template_mobilization:template }
      let(:tempalte_widget_2_1) { TemplateWidget.make! template_block:template_block_2 }
      let(:tempalte_widget_2_2) { TemplateWidget.make! template_block:template_block_2 }

      before do
        @template_blocks  = [template_block_1, template_block_2]
        @template_widgets = [tempalte_widget_1_1, tempalte_widget_1_2, tempalte_widget_2_1, tempalte_widget_2_2]

        put :update, { mobilization: { template_mobilization_id: template.id } , id: mobilization.id }
      end

      it { should respond_with 200 }


      it "should update data from a template" do
        expect(saved_mobilization.header_font).to eq(template.header_font)
      end

      it "should not update name from a mobilization" do
        expect(saved_mobilization.name).to eq(mobilization.name)
      end

      it "should not update goal from a mobilization" do
        expect(saved_mobilization.goal).to eq(mobilization.goal)
      end

      it "should return the new data" do
        expect(response.body).to include(template.header_font)
      end

      it 'should increment the uses_number for each use' do
        newTemplate = TemplateMobilization.find template.id
        expect(newTemplate.uses_number).to eq((template.uses_number||0) + 1)
      end

      it 'should save the blocks in the right sequence' do
        template_blocs_names = @template_blocks.map{|template_block| template_block.name }

        blocks_names = saved_mobilization.blocks.order(:id).map{|block| block.name}

        expect(blocks_names).to eq(template_blocs_names)
      end

      it 'should save the blocks in the right sequence' do
        template_widgets_settings = @template_widgets.map{|template_widget| template_widget.settings['other'] }

        blocks_widgets_settings = (saved_mobilization.blocks.order(:id).map{|block| block.widgets.order(:id)}).flatten.map {|w| w.settings['other']}

        expect(blocks_widgets_settings).to eq(template_widgets_settings)
      end
    end

    context "update from an inexisting template" do
      before { put :update, { mobilization: { template_mobilization_id: 0 }, id: mobilization.id } }

      it { should respond_with 404 }
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
          community_id: community.id,
          tag_list: "luta, corrupção"
        }

        expect(Mobilization.count).to eq(1)
        expect(response.body).to include('tag_list')
        expect(response.body).to include('luta')
        expect(response.body).to include('corrupcao')
        expect(response.body).to include('Foo')
        expect(response.body).to include('Bar')
      end
    end
  end
end
