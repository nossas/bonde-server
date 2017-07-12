require 'rails_helper'

RSpec.describe Mobilizations::BlocksController, type: :controller do
  let(:user) { User.make! }
  let(:user_admin) { User.make! admin: true }

  before do
    stub_current_user(user)
  end

  describe "GET #index" do
    it "should return blocks by mobilization" do
      mobilization1 = Mobilization.make!
      mobilization2 = Mobilization.make!
      block1 = Block.make! mobilization: mobilization1
      block2 = Block.make! mobilization: mobilization2

      get :index, mobilization_id: mobilization1.id

      expect(response.body).to include(block1.to_json)
      expect(response.body).to_not include(block2.to_json)
    end
  end

  describe "POST #create" do
    context 'User in community list' do
      let(:mobilization) { Mobilization.make! }
      before { CommunityUser.create! user_id: user.id, community_id: mobilization.community.id, role: 1 }
      
      it "should create with JSON format and empty params" do
        mobilization = Mobilization.make!
        expect(mobilization.blocks.count).to eq(0)
        post :create, mobilization_id: mobilization.id, format: :json

        expect(mobilization.blocks.count).to eq(1)
        expect(response.body).to include(BlockSerializer::CompleteBlockSerializer.new(mobilization.blocks.first).to_json)
      end

      it "should create with JSON format and parameters" do
        mobilization = Mobilization.make!
        expect(mobilization.blocks.count).to eq(0)
        post :create, mobilization_id: mobilization.id, format: :json, block: { position: 12345, bg_class: 'bg-yellow', bg_image: 'foobar.jpg', hidden: true }

        expect(mobilization.blocks.count).to eq(1)
        block = mobilization.blocks.first
        expect(response.body).to include(BlockSerializer::CompleteBlockSerializer.new(block).to_json)
        expect(block.position).to eq(12345)
        expect(block.bg_class).to eq('bg-yellow')
        expect(block.bg_image).to eq('foobar.jpg')
        expect(block.hidden).to eq(true)
      end

      it "should create nested widgets" do
        mobilization = Mobilization.make!
        expect(mobilization.blocks.count).to eq(0)
        post :create, mobilization_id: mobilization.id, format: :json, block: { widgets_attributes: [{kind: 'content', sm_size: 8, md_size: 6, lg_size: 6}, {kind: 'weather', sm_size: 12, md_size: 12, lg_size: 4}] }
        expect(mobilization.blocks.count).to eq(1)
        block = mobilization.blocks.first
        expect(response.body).to include(BlockSerializer::CompleteBlockSerializer.new(block).to_json)
        expect(block.widgets.count).to eq(2)
        widget1 = block.widgets[0]
        widget2 = block.widgets[1]
        expect(widget1.kind).to eq('content')
        expect(widget1.sm_size).to eq(8)
        expect(widget1.md_size).to eq(6)
        expect(widget1.lg_size).to eq(6)
        expect(widget2.kind).to eq('weather')
        expect(widget2.sm_size).to eq(12)
        expect(widget2.md_size).to eq(12)
        expect(widget2.lg_size).to eq(4)
      end

      context 'mobilization does not exists' do
        before do
          post :create, mobilization_id: 0, format: :json
        end

        it 'should return a 400 status' do
          expect(response.status).to be 400
        end

        it 'should return an advice message' do
          expect(response.body).to include('Mobilization')
        end
      end
    end


    context 'User admin' do
      let(:mobilization) { Mobilization.make! }
      before { stub_current_user(user_admin) }

      it "should create with JSON format and empty params" do
        expect(mobilization.blocks.count).to eq(0)

        post :create, mobilization_id: mobilization.id, format: :json

        expect(mobilization.blocks.count).to eq(1)
        expect(response.body).to include(mobilization.blocks.first.to_json)
      end
    end

    context 'User not from community' do
      let(:mobilization) { Mobilization.make! }
      before { stub_current_user(User.make) }

      it "should return a 401" do
        expect(mobilization.blocks.count).to eq(0)

        post :create, mobilization_id: mobilization.id, format: :json

        expect(response.status).to be 401
      end
    end
  end

  describe "PUT #update" do
    let(:mobilization) { Mobilization.make! }

    context 'User in community\'s list' do
      let(:block) { Block.make! mobilization: mobilization, bg_class: 'bg-white', position: 123, hidden: false }

      before do
        CommunityUser.create! user_id: user.id, community_id: mobilization.community.id, role: 1

        put :update, mobilization_id: mobilization.id, id: block.id, format: :json, block: { position: 321, bg_class: 'bg-yellow', bg_image: 'foobar.jpg',  hidden: true }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end
      
      it "should update with JSON format" do
        block.reload
        expect(block.position).to eq(321)
        expect(block.bg_class).to eq('bg-yellow')
        expect(block.bg_image).to eq('foobar.jpg')
        expect(block.hidden).to eq(true)
        expect(response.body).to include(block.to_json)
      end
    end

    context 'User not in community\'s list' do
      let(:block) { Block.make! mobilization: mobilization, bg_class: 'bg-white', position: 123, hidden: false }

      before do
        put :update, mobilization_id: mobilization.id, id: block.id, format: :json, block: { position: 321, bg_class: 'bg-yellow', bg_image: 'foobar.jpg',  hidden: true }
      end

      it 'should return a 401 status' do
        expect(response.status).to be 401
      end
    end

    context 'User is an admin' do
      let(:block) { Block.make! mobilization: mobilization, bg_class: 'bg-white', position: 123, hidden: false }

      before do
        stub_current_user(user_admin)

        put :update, mobilization_id: mobilization.id, id: block.id, format: :json, block: { position: 321, bg_class: 'bg-yellow', bg_image: 'foobar.jpg',  hidden: true }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end
    end

    context 'block not exists' do
      it 'should return status 404' do
        put :update, mobilization_id: mobilization.id, id: 0, format: :json, block: { position: 321, bg_class: 'bg-yellow', bg_image: 'foobar.jpg',  hidden: true }
        expect(response.status).to be 404
      end
    end
  end


  describe "DELETE #destroy" do
    let(:mobilization) { Mobilization.make! }

    before do 
      @block = Block.make! mobilization: mobilization, bg_class: 'bg-white', position: 123, hidden: false
      @count = mobilization.blocks.count 
    end

    context 'user in community\'s list' do
      before do
        CommunityUser.create! user_id: user.id, community_id: mobilization.community.id, role: 1

        delete :destroy, mobilization_id: mobilization.id, id: @block.id, format: :json
      end

      it 'should return status 200' do
        expect(response.status).to be 200
      end
      
      it "should destroy with JSON format" do
        expect(mobilization.blocks.count).to eq(@count - 1)
        expect(response.body).to include(@block.to_json)
      end
    end

    context 'user is mobilization\'s creator' do
      before do
        mobilization.update_attributes user_id: user.id
        delete :destroy, mobilization_id: mobilization.id, id: @block.id, format: :json
      end

      it 'should return status 200' do
        expect(response.status).to be 200
      end
    end

    context 'user not in community\'s list' do
      before do
        delete :destroy, mobilization_id: mobilization.id, id: @block.id, format: :json
      end

      it 'should return status 401' do
        expect(response.status).to be 401
      end
    end

    context 'user is an admin' do
      before do
        stub_current_user user_admin
        delete :destroy, mobilization_id: mobilization.id, id: @block.id, format: :json
      end

      it 'should return status 200' do
        expect(response.status).to be 200
      end
      
      it "should destroy with JSON format" do
        expect(mobilization.blocks.count).to eq(@count - 1)
        expect(response.body).to include(@block.to_json)
      end
    end

    context 'block not exists' do
      it 'should return status 404' do
        delete :destroy, mobilization_id: mobilization.id, id: 0, format: :json
        expect(response.status).to be 404
      end
    end
  end
end
