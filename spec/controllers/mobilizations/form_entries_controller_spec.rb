require 'rails_helper'

RSpec.describe Mobilizations::FormEntriesController, type: :controller do
  let(:user) { User.make! }
  let(:mobilization) { Mobilization.make! user: user }
  let(:block) { Block.make! mobilization: mobilization }
  let(:widget) { Widget.make! block: block }
  let(:current_user) { user }

  before do
    widget
    stub_current_user(current_user)
  end

  describe "GET #index" do

    context "when access with not mobilization user" do
      let(:current_user) { User.make! }

      it "should raise record not found" do
        expect do
          get :index, mobilization_id: mobilization.id
        end.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "when access with mobilization user" do
      let!(:form_entry) { FormEntry.make! widget: widget }
      before { get :index, mobilization_id: mobilization.id }
      it { is_expected.to respond_with 200 }
    end
  end

  describe "POST #create" do
    it "should create with JSON format and parameters" do
      expect(widget.form_entries.count).to eq(0)
      post(
        :create,
        mobilization_id: widget.mobilization.id,
        format: :json,
        form_entry: {
          widget_id: widget.id,
          fields: [{kind: 'email', value: 'foo@validemail.com'}].to_json
        }
      )
      expect(widget.form_entries.count).to eq(1)
      form_entry = widget.form_entries.first
      expect(response.body).to include(form_entry.to_json)
      expect(form_entry.widget_id).to eq(widget.id)
      expect(form_entry.fields).to eq([{
        kind: 'email',
        value: 'foo@validemail.com'
      }].to_json)
    end
  end
end
