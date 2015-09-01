require 'rails_helper'

RSpec.describe Mobilizations::FormEntriesController, type: :controller do
  before do
    @user = User.make!
    stub_current_user(@user)
  end

  describe "POST #create" do
    it "should create with JSON format and parameters" do
      widget = Widget.make!
      expect(widget.form_entries.count).to eq(0)
      post :create, mobilization_id: widget.mobilization.id, format: :json, form_entry: { widget_id: widget.id, fields: 'ABC' }
      expect(widget.form_entries.count).to eq(1)
      form_entry = widget.form_entries.first
      expect(response.body).to include(form_entry.to_json)
      expect(form_entry.widget_id).to eq(widget.id)
      expect(form_entry.fields).to eq('ABC')
    end
  end
end
