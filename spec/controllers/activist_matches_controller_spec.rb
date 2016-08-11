
require 'rails_helper'

RSpec.describe ActivistMatchesController, type: :controller do
  let(:user) { User.make! }
  let(:mobilization) { Mobilization.make! user: user }
  let(:block) { Block.make! mobilization: mobilization }
  let(:widget) { Widget.make! block: block }
  let(:match) { Match.make! widget: widget }
  let(:activist) { Activist.make! }
  let(:activist_match) { ActivistMatch.make! match: match, activist: activist }
  let(:current_user) { user }

  before do
    stub_current_user(current_user)
    match
  end

  shared_examples "public access" do
    context "when user is mobilization owner" do
      it { is_expected.to respond_with 200 }
    end

    context "when user is not mobilization owner" do
      let(:current_user) { User.make! }
      it { is_expected.to respond_with 200 }
    end
  end

  describe "POST #create" do
    before {
      post :create,
      activist_match: { match_id: match, activist: { name: 'Foo Bar', email: 'foo@bar.org' } }
    }

    it_behaves_like "public access"
  end
end
