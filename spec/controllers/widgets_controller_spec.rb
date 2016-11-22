require 'rails_helper'

RSpec.describe WidgetsController, type: :controller do
  before do
    @user = User.make!
    stub_current_user(@user)
  end

  describe 'GET #index' do
    it 'should return widgets by mobilization\'s custom domain' do
      mobilization = Mobilization.make!
      block = Block.make! mobilization: mobilization
      widget = Widget.make! block: block

      get :index, custom_domain: mobilization.custom_domain

      expect(response.body).to include(widget.to_json)
    end

    it 'should return widgets by mobilization\'s slug' do
      mobilization = Mobilization.make!
      block = Block.make! mobilization: mobilization
      widget = Widget.make! block: block

      get :index, slug: mobilization.slug

      expect(response.body).to include(widget.to_json)
    end
  end
end
