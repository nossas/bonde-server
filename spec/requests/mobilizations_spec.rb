require 'rails_helper'

RSpec.describe "Mobilizations", type: :request do
  let!(:community) { create :community }
  let!(:logged_user) { create :user }

  before { stub_current_user(logged_user) }

  describe "POST /community/:community_id/mobilizations" do

    xcontext "single creation" do
      it "should create with JSON format" do
        expect(Mobilization.count).to eq(0)

        post "/community/:community_id/mobilizations", {
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

    context "repeated custom_domain" do
      let(:mobilization) { create :mobilization, custom_domain: 'egaliteliberteetfraternite.fr' }

      before do
        post "/mobilizations", { format: :json, mobilization: {
          name: 'Foo',
          goal: 'Bar',
          community_id: community.id,
          tag_list: "luta, corrupção",
          custom_domain: mobilization.custom_domain
        } }
      end

      it {expect(response).to have_http_status(422)}
    end
  end

end