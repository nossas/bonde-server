
require 'rails_helper'

RSpec.describe Widgets::MatchController, type: :controller do
  let(:user) { User.make! }
  let(:mobilization) { Mobilization.make! user: user }
  let(:block) { Block.make! mobilization: mobilization }
  let(:widget) { Widget.make! block: block }
  let(:match) { Match.make! widget: widget }
  let(:current_user) { user }

  before do
    stub_current_user(current_user)
    match
  end

  shared_examples "user access" do
    context "when user is mobilization owner" do
      it { is_expected.to respond_with 200 }
    end

    context "when user is not mobilization owner" do
      let(:current_user) { User.make! }
      it { is_expected.to respond_with 401 }
    end
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

  describe "GET #show" do
    before  { get :show, widget_id: match.widget_id, id: match.id }

    it_behaves_like "public access"
  end

  describe "POST #create" do
    before  { post :create, widget_id: match.widget_id, match: {first_choice: 'lorem', second_choice: 'ipsum', goal_image: 'goal_image2'} }

    it_behaves_like "user access"
  end

  describe "PUT #update" do
    before  { put :update, widget_id: match.widget_id, id: match.id, match: { first_choice: 'foo'} }

    it_behaves_like "user access"
  end

  describe "DELETE #destroy" do
    before  { delete :destroy, widget_id: match.widget_id, id: match.id }
    it_behaves_like "user access"
  end

  describe "DELETE delete_where" do
    let!(:match_2) { Match.make! widget: widget, first_choice: 'foo' }
    let!(:match_3) { Match.make! widget: widget, first_choice: 'foo' }

    before { delete :delete_where, widget_id: match.widget_id, match: { first_choice: 'foo'} }

    it_behaves_like "user access"

    it "should have deleted all matchs that match with filters" do
      expect(widget.matches.size).to eq(1)
    end
  end
end
