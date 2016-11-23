require 'rails_helper'

RSpec.describe WidgetsController, type: :controller do
  before do
    @user = User.make!
    stub_current_user(@user)
  end

  describe 'GET #index' do
    before do
      mobilization = Mobilization.make!
      block = Block.make! mobilization: mobilization
      @widget = Widget.make! block: block

      get :index, custom_domain: mobilization.custom_domain
    end
    
    it 'should return widgets by mobilization\'s custom domain' do
      expect(response.body).to include(@widget.to_json)
    end

    it 'should return 200 status' do
      expect(response.status).to be 200
    end
  end
end
