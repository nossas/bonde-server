require 'rails_helper'

RSpec.describe "FormEntries", type: :request do
  let(:user) { create(:user) }

  before { stub_current_user(user) }

  describe 'GET /mobilizations/:mobilization_id/form_entries' do
    let!(:widget) { create :widget }

    let!(:form_entry_1) { create :form_entry, widget: widget }
    let!(:form_entry_2) { create :form_entry }

    context 'format csv joint_fields' do
      before { get "/mobilizations/#{widget.mobilization.id}/form_entries.csv?widget_id=#{widget.id}&INFO=disjoint_fields" }

      it { expect(response).to have_http_status(200) }

      it do
        expect(response.body).to include('email')
        expect(response.body).to include('first name')
        expect(response.body).to include('last name')
        expect(response.body).not_to include('fields')
      end
    end

    context 'format csv' do
      before { get "/mobilizations/#{widget.mobilization.id}/form_entries.csv?widget_id=#{widget.id}" }

      it { expect(response).to have_http_status(200) }

      it do
        expect(response.body).to include('fields')
      end
    end
  end

end
