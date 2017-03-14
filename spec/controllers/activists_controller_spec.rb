require 'rails_helper'

RSpec.describe ActivistsController, type: :controller do
  let!(:community) { Community.make! }
  let!(:user) { User.make! admin: true}

  before do
    CommunityUser.create community: community, user: user, role: 1
    stub_current_user user

  end

  xdescribe "#add_activists" do 
    before do
      @request.env["CONTENT_TYPE"] = "text/csv"
      request.env['RAW_POST_DATA'] = "nome,email\nMe,me@nossas.org\nYou,you@nossas.org"
      post :add_activists, community_id: community.id
    end

    it { should respond_with 200 }
  end
end
