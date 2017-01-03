require 'rails_helper'

RSpec.describe MobilizationsController, type: :controller do
  let!(:user1) { create :user }
  let!(:user2) { create :user }

  before { stub_current_user(user1) }


  describe "GET #index" do
    let!(:mob1) { Mobilization.make! user: user1, custom_domain: "foobar", slug: "1-foo" }
    let!(:mob2) { Mobilization.make! user: user2 }

    # Temporary removed - see comments on implementation
    xcontext "unlogged user" do
      before do
        stub_current_user nil
        get :index
      end

      it { expect(response.status).to be 401 }
    end


    it "should return all mobilizations" do
      get :index

      expect(response.body).to include(mob1.name)
      expect(response.body).to include(mob2.name)
    end

    it "should return mobilizations by user" do
      get :index, user_id: user1.id

      expect(response.body).to include(mob1.name)
      expect(response.body).to_not include(mob2.name)
    end

    it "should return mobilizations by custom_domain" do
      get :index, custom_domain: "foobar"

      expect(response.body).to include(mob1.name)
      expect(response.body).to_not include(mob2.name)
    end

    it "should return mobilizations by slug" do
      get :index, slug: "1-foo"

      expect(response.body).to include(mob1.name)
      expect(response.body).to_not include(mob2.name)
    end

    it "should return mobilizations by id" do
      get :index, ids: [mob1.id]

      expect(response.body).to include(mob1.name)
      expect(response.body).to_not include(mob2.name)
    end
  end

<<<<<<< HEAD
  describe 'PATCH #update' do
    context 'update an existing Mobilization' do
      subject {
        Mobilization.make! user: user1
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
    let(:mobilization) { Mobilization.make! user: user1, slug: nil }
=======


  describe 'PATCH #update' do
    let(:template) { TemplateMobilization.make! }
    let(:mobilization) { Mobilization.make!  user: user2 }
    let(:saved_mobilization) { Mobilization.find mobilization.id }


    context "update an existing Mobilization from an existing template" do
      let(:template_block_1) { TemplateBlock.make! template_mobilization:template }
      let(:template_widget_1_1) { TemplateWidget.make! template_block:template_block_1 }
      let(:tempalte_widget_1_2) { TemplateWidget.make! template_block:template_block_1 }
      let(:template_block_2) { TemplateBlock.make! template_mobilization:template }
      let(:tempalte_widget_2_1) { TemplateWidget.make! template_block:template_block_2 }
      let(:tempalte_widget_2_2) { TemplateWidget.make! template_block:template_block_2 }

      before do
        stub_current_user user2
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

<<<<<<< HEAD
    context "update from an inexisting template" do
      before { put :update, { mobilization: { template_mobilization_id: 0 }, id: mobilization.id } }
=======
    context 'Mobilization' do    
      context 'user not in community\'s list' do
        before do
          patch :update, {format: :json, mobilization: {name: 'super-hiper-marevelous mobilization'}, id: mobilization.id}
        end

        it 'should return an 401' do
          expect(response).to be_unauthorized
        end
      end

      context 'user in community\'s list' do
        before do
          CommunityUser.create! user_id: user1.id, community_id: mobilization.community.id, role: 1
          patch :update, {format: :json, mobilization: {name: 'super-hiper-marevelous mobilization'}, id: mobilization.id}
        end

        it 'should change data in database' do
          expect((Mobilization.find mobilization.id).name).to eq('super-hiper-marevelous mobilization')
        end

        it 'should return an 200' do
          expect(response.status).to be 200
        end
      end

      context 'user is admin' do
        before do
          user1.update_attributes admin: true
          patch :update, {format: :json, mobilization: {name: 'super-hiper-marevelous mobilization'}, id: mobilization.id}
        end
>>>>>>> [#136390875] Mobilization revised

        it 'should change data in database' do
          expect((Mobilization.find mobilization.id).name).to eq('super-hiper-marevelous mobilization')
        end

        it 'should return an 200' do
          expect(response.status).to be 200
        end
      end

      context 'mobilization does not exist' do
        it 'should return a 404 (not found) status' do
          patch :update, {format: :json, mobilization: {name: 'super-hiper-marevelous mobilization'}, id: 0}

          expect(response).to be_not_found
        end
      end
  
      context 'from Template' do
        let(:template) { TemplateMobilization.make! }
        let(:block) { TemplateBlock.make! template_mobilization:template }
        
        before do
          TemplateWidget.make! template_block:block
          
          stub_request(:delete, "https://api.heroku.com/apps//domains/mymobilization").
            with(:headers => {'Accept'=>'application/vnd.heroku+json; version=3', 'Authorization'=>'Bearer ', 'Host'=>'api.heroku.com:443', 'User-Agent'=>'excon/0.45.4'}).
            to_return(:status => 200, :body => "", :headers => {})
        end

        context "admin user" do
          before do
            user1.update_attributes admin: true

            put :update, { template_mobilization_id: template.id, id: mobilization.id }
          end

          it "should return a 200 status if created" do
            expect(response.status).to eq(200)
          end

          it "should update data from a template" do
            mob = Mobilization.find mobilization.id
            expect(mob.header_font).to eq(template.header_font)
          end

          it "should not update name from a mobilization" do
            mob = Mobilization.find mobilization.id
            expect(mob.name).to eq(mobilization.name)
          end

          it "should not update goal from a mobilization" do
            mob = Mobilization.find mobilization.id
            expect(mob.goal).to eq(mobilization.goal)
          end

          it "should return the new data" do
            expect(response.body).to include(template.header_font)
          end

          it 'should increment the uses_number for each use' do
            newTemplate = TemplateMobilization.find template.id
            expect(newTemplate.uses_number).to eq((template.uses_number||0) + 1)
          end
        end

        context "user in community's list" do
          before do
            CommunityUser.create! community_id: mobilization.community.id, user_id: user1.id, role: 1

            put :update, { template_mobilization_id: template.id, id: mobilization.id }
          end

          it "should return a 200 status if created" do
            expect(response.status).to eq(200)
          end

          it "should update data from a template" do
            mob = Mobilization.find mobilization.id
            expect(mob.header_font).to eq(template.header_font)
          end

          it "should not update name from a mobilization" do
            mob = Mobilization.find mobilization.id
            expect(mob.name).to eq(mobilization.name)
          end

          it "should not update goal from a mobilization" do
            mob = Mobilization.find mobilization.id
            expect(mob.goal).to eq(mobilization.goal)
          end

          it "should return the new data" do
            expect(response.body).to include(template.header_font)
          end

          it 'should increment the uses_number for each use' do
            newTemplate = TemplateMobilization.find template.id
            expect(newTemplate.uses_number).to eq((template.uses_number||0) + 1)
          end
        end

        context "user in community's list" do
          before do
            put :update, { template_mobilization_id: template.id, id: mobilization.id }
          end

          it "should return a 401 status" do
            expect(response).to be_unauthorized
          end
        end

        context "update from an inexisting template" do
          it "should return a 404 status" do
            put :update, { template_mobilization_id: 0, id: mobilization.id }

            expect(response.status).to eq(404)
          end
        end
      end
    end

    context "fields changing validation" do
      before { put :update, { mobilization: { 
        name: 'new name',
        slug: 'my slug',
        custom_domain: 'anewdomainfor.us'
      }, id: mobilization.id } }

      it { should respond_with 200 }
      
      it { expect(assigns(:mobilization).name).to eq('new name')}

      it { expect(assigns(:mobilization).slug).to eq('my slug')}

      it { expect(assigns(:mobilization).custom_domain).to eq('anewdomainfor.us')}
    end
  end
<<<<<<< HEAD


  describe "POST #create" do
    let!(:community) { create :community }

    context "single creation" do
      it "should create with JSON format" do
        expect(Mobilization.count).to eq(0)
=======

  describe "POST #create" do
    let(:community){ Community.make! }
>>>>>>> [#136390875] Mobilization revised

    context "user not in comuunity's users list - single creation" do
      before do
        post :create, format: :json, mobilization: {
          name: 'Foo',
          goal: 'Bar',
          community_id: community.id,
          tag_list: "luta, corrupção"
        }
      end
      
      it 'should return a 401 status' do
        expect(response).to be_unauthorized
      end
    end

    context "user in comuunity's users list - single creation" do
      before do
        CommunityUser.create! user_id: user1.id, community_id: community.id, role: 1
        @count = Mobilization.count

<<<<<<< HEAD
        expect(Mobilization.count).to eq(1)
        expect(response.body).to include('tag_list')
        expect(response.body).to include('luta')
        expect(response.body).to include('corrupcao')
        expect(response.body).to include('Foo')
        expect(response.body).to include('Bar')
=======
        post :create, format: :json, mobilization: {
          name: 'Foo',
          goal: 'Bar',
          community_id: community.id
        }
      end
      
      it "should create with JSON format" do    
        expect(Mobilization.count).to eq(@count+1)
        expect(response.body).to include(Mobilization.first.to_json)
>>>>>>> [#136390875] Mobilization revised
      end

      it 'should return a 200 status' do
        expect(response).to be_ok
      end

      it "should return the values saved" do
          expect(response.body).to include("\"name\":\"Foo\"")
          expect(response.body).to include("\"goal\":\"Bar\"")
          expect(response.body).to include("\"community_id\":#{community.id}")
      end
    end

    context "user is admin - single creation" do
      before do
        user1.update_attributes admin: true
        @count = Mobilization.count

        post :create, format: :json, mobilization: {
          name: 'Foo',
          goal: 'Bar',
          community_id: community.id
        }
      end
      
      it "should create with JSON format" do    
        expect(Mobilization.count).to eq(@count+1)
        expect(response.body).to include(Mobilization.first.to_json)
      end

      it 'should return a 200 status' do
        expect(response).to be_ok
      end

      it "should return the values saved" do
          expect(response.body).to include("\"name\":\"Foo\"")
          expect(response.body).to include("\"goal\":\"Bar\"")
          expect(response.body).to include("\"community_id\":#{community.id}")
      end
    end

    context "repeated custom_domain" do
    end
  end
end
