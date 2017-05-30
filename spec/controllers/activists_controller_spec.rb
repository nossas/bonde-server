require 'rails_helper'

RSpec.describe ActivistsController, type: :controller do
  let!(:community) { Community.make! }
  let!(:user) { User.make! admin: true}

  before do
    CommunityUser.create community: community, user: user, role: 1
    stub_current_user user
  end

  describe "#add_activists" do 
    before do
      @activist_count = Activist.count
      @request.env["CONTENT_TYPE"] = "text/csv"
      request.env['RAW_POST_DATA'] = %(name,email,tags
It's Me,me@nossas.org,me;myself;only me
That's You,you@nossas.org,you;yourself;only you)

      post :add_activists, community_id: community.id
    end

    it { should respond_with 200 }

    it { expect(assigns(:return_list).count).to be 2 }

    it { expect(Activist.count).to be(@activist_count + 2) }

    it 'should create taglist for the first record' do
      list = assigns(:return_list)
      ['me','myself','only-me'].each {|tg| expect(list[0].tag_list community.id).to include tg}
    end

    it 'should create taglist for the second record' do
      list = assigns(:return_list)
      ['you','yourself','only-you'].each {|tg| expect(list[1].tag_list community.id).to include  tg}
    end
  end
end
