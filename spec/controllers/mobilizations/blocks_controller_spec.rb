require 'rails_helper'

RSpec.describe Mobilizations::BlocksController, type: :controller do
  before do
    @user = User.make!
    stub_current_user(@user)
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
  end

  describe "PUT #update" do
    it "should update with JSON format" do
      mobilization = Mobilization.make! user: @user
      block = Block.make! mobilization: mobilization, bg_class: 'bg-white', position: 123, hidden: false
      put :update, mobilization_id: mobilization.id, id: block.id, format: :json, block: { position: 321, bg_class: 'bg-yellow', bg_image: 'foobar.jpg',  hidden: true }
      block.reload
      expect(block.position).to eq(321)
      expect(block.bg_class).to eq('bg-yellow')
      expect(block.bg_image).to eq('foobar.jpg')
      expect(block.hidden).to eq(true)
      expect(response.body).to include(block.to_json)
    end
  end

  describe "DELETE #destroy" do
    it "should destroy with JSON format" do
      mobilization = Mobilization.make! user: @user
      block = Block.make! mobilization: mobilization, bg_class: 'bg-white', position: 123, hidden: false
      expect(mobilization.blocks.count).to eq(1)
      delete :destroy, mobilization_id: mobilization.id, id: block.id, format: :json
      expect(mobilization.blocks.count).to eq(0)
      expect(response.body).to include(block.to_json)
    end
  end

end
