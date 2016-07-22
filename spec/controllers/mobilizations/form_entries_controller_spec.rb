require 'rails_helper'

RSpec.describe Mobilizations::FormEntriesController, type: :controller do
  let(:user) { User.make! }
  let(:mobilization) { Mobilization.make! user: user }
  let(:block) { Block.make! mobilization: mobilization }
  let(:widget) { Widget.make! block: block }
  let(:widget2) { Widget.make! block: block }
  let(:current_user) { user }

  before do
    widget
    widget2
    stub_current_user(current_user)
  end

  describe "GET #index" do
    context "when access with user" do
      let!(:form_entry) { FormEntry.make! widget: widget }
      let!(:form_entry2) { FormEntry.make! widget: widget2 }

      it "should return form_entries by mobilization" do
        get(:index, mobilization_id: mobilization.id)
        expect(response.body).to eq([form_entry, form_entry2].to_json)
      end

      it "should return form_entries by widget_id" do
        get(:index, mobilization_id: mobilization.id, widget_id: widget.id)
        expect(response.body).to eq([form_entry].to_json)
      end
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
