require 'rails_helper'

RSpec.describe "Mobilizations", type: :request do
  let!(:community) { create :community }
  let!(:logged_user) { create :user, admin: true }

  before { stub_current_user(logged_user) }

  describe "POST /mobilizations" do

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

  describe "PATCH /mobilizations/:id" do
    let!(:mobilization) { create :mobilization, custom_domain: 'egaliteliberteetfraternite.fr' }

    before do
      patch "/mobilizations/#{mobilization.id}", { format: :json, mobilization: {
        slug: 'my-little-slug',
        custom_domain: 'www.mydomain.org'
      }
    }
    end

    it {expect(response).to have_http_status(200)}

    it {expect(response.body).to include('my-little-slug')}

    it {expect(response.body).to include('www.mydomain.org')}
  end

end