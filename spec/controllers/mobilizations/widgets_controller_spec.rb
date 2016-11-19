require 'rails_helper'

RSpec.describe Mobilizations::WidgetsController, type: :controller do
  before do
    @widget1 = Widget.make!
    @widget2 = Widget.make!
    @user = User.make! admin: false
    @admin = User.make! admin: true
    stub_current_user(@user)
  end

  describe "GET #index" do
    context "on valid call" do
      before do
        get :index, mobilization_id: @widget1.block.mobilization_id
      end

      it "should return widgets by mobilization" do
        expect(response.body).to include(@widget1.to_json)
        expect(response.body).to_not include(@widget2.to_json)
      end

      it "should return a 200 status" do
        expect(response.status).to be 200
      end
    end
  end

  describe "PUT #update" do
    context 'with valid payload' do
      it "should update widget when current user is admin" do
        stub_current_user(@admin)
        put :update, update_widget_1_params

        expect(response.body).to include("Widget new content")
      end

      it "should update widget when current user is the mobilization's owner" do
        stub_current_user(@widget1.mobilization.user)
        put :update, update_widget_1_params

        expect(response.body).to include("Widget new content")
      end

      it "should return 401 if user is not an admin or mobilization's owner" do
        stub_current_user(User.make!)
        put :update, update_widget_1_params

        expect(response).to be_unauthorized
      end

      context "with huge emails(500) for target pressure"
      before do
        stub_current_user(@admin)
        widget_smpl = Widget.make!
        widget = Widget.find widget_smpl.id
        @generated_emails = 'Pression tests from OurCities Gang <meuemail@lutas.sao.nossas.org>'
        (2..500).each do  |idx|
          @generated_emails += ";Pression tests from OurCities Gang #{idx} <meuemail#{idx}@lutas.sao.nossas.org>"
        end

        put :update, {
          mobilization_id: widget.block.mobilization.id,
          id: widget.id,
          widget: {
            id: widget.id,
            block_id: widget.block.id,
            kind: "pressure",
            settings: {
              title_text: "Stopping legal salary increases from judiciary",
              main_color: "#757ef1",
              button_text: "ighting to an end",
              count_text: "pressures made",
              show_counter: "true",
              reply_email: "foo@bar.com",
              pressure_subject: "Stopping legal salary increases from judiciary",
              pressure_body: "Let'a stop with this $@#%! piece of @#%@#@#@ !!!!",
              targets: @generated_emails
            },
            sm_size: 12,
            md_size: 12,
            lg_size: 12,
            form_entries_count: 0,
            donations_count: 0,
            created_at: widget.created_at,
            updated_at: widget.updated_at,
            action_community: false,
            action_opportunity: false,
            exported_at: nil,
            match_list: [],
            count: 0        
          },
          format: 'json'
        }
      end

      it 'should return 200 status' do
        expect(response.status).to be 200
      end

      it 'should return the emails saved data' do
        expect(response.body).to include('meuemail@lutas.sao.nossas.org')
      end
    end
  end
end

def update_widget_1_params
  {
    mobilization_id: @widget1.block.mobilization_id,
    id: @widget1.id,
    widget: {
      settings: {
        content: "Widget new content"
      }
    }
  }
end
