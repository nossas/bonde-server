# coding: utf-8
require 'rails_helper'

RSpec.describe Mobilizations::FormEntriesController, type: :controller do
  let(:user) { User.make! }
  let(:mobilization) { Mobilization.make! user: user }
  let(:block) { Block.make! mobilization: mobilization }
  let(:widget) { Widget.make! block: block }
  let(:widget2) { Widget.make! block: block }
  let(:current_user) { User.make! admin: false }

  before do
    widget
    widget2
    stub_current_user(current_user)
  end

  describe "GET #index" do
    context 'with full_info flag' do
      context "when access with user" do
        let!(:form_entry) { FormEntry.make! widget: widget }
        let!(:form_entry2) { FormEntry.make! widget: widget2 }

        def fields_generated(fe)
          {
            'activist_id' => fe.activist_id,
            'created_at' => fe.created_at,
            'email' => 'zemane@naoexiste.com',
            'first name' => 'José',
            'id' => fe.id,
            'last name' => 'manuel',
            'requester' => current_user.id,
            'updated_at' => fe.updated_at,
            'widget_id' => fe.widget_id
          }
        end

        it "should return form_entries by mobilization" do
          get(:index, { mobilization_id: mobilization.id, INFO: 'disjoint_fields' })
          expect(assigns(:form_entries)).to eq([fields_generated(form_entry), fields_generated(form_entry2)])
        end

        it "should return form_entries by widget_id" do
          get(:index, { mobilization_id: mobilization.id, widget_id: widget.id, INFO: 'disjoint_fields'})

          widget.reload
          expect(assigns(:form_entries)).to eq([fields_generated(form_entry)])
          expect(widget.exported_at).not_to eq(nil)
        end
      end
    end

    context 'without INFO' do
      context "when access with user" do
        let!(:form_entry) { FormEntry.make! widget: widget }
        let!(:form_entry2) { FormEntry.make! widget: widget2 }

        it "should return form_entries by mobilization" do
          get(:index, mobilization_id: mobilization.id)
          expect(assigns(:form_entries)).to eq([form_entry, form_entry2])
        end

        it "should return form_entries by widget_id" do
          get(:index, mobilization_id: mobilization.id, widget_id: widget.id)

          widget.reload
          expect(assigns(:form_entries)).to eq([form_entry])
          expect(widget.exported_at).not_to eq(nil)
        end
      end
    end
  end

  describe "POST #create" do
    context "valid call" do
      before do 
        post(
          :create,
          mobilization_id: widget.mobilization.id,
          format: :json,
          form_entry: {
            widget_id: widget.id,
            fields: [
              { kind: 'email', label: 'email', value: 'foo@validemail.com' },
              { kind: 'text', label: 'first name', value: 'foo' },
              { kind: 'text', label: 'last name', value: 'bar' }
            ].to_json
          }
        )
      end

      it "should create with JSON format and parameters" do
        expect(widget.form_entries.count).to eq(1)
        form_entry = widget.form_entries.first
        expect(response.body).to include(form_entry.to_json)
        expect(form_entry.widget_id).to eq(widget.id)
        expect(form_entry.fields).to eq([
          { kind: 'email', label: 'email', value: 'foo@validemail.com' },
          { kind: 'text', label: 'first name', value: 'foo' },
          { kind: 'text', label: 'last name', value: 'bar' }
        ].to_json)
      end

      it "message status should be a 200" do
        expect(response.status).to be 200
      end

      it "should put a message on Sidekiq" do
        form_entry = widget.form_entries.first
        sidekiq_jobs = MailchimpSyncWorker.jobs
        expect(sidekiq_jobs.size).to eq(1)
        expect(sidekiq_jobs.last['args']).to eq([form_entry.id, 'formEntry'])
      end
    end

    context "invalid email" do
      before do 
        post(
          :create,
          mobilization_id: widget.mobilization.id,
          format: :json,
          form_entry: {
            widget_id: widget.id,
            fields: [
              {kind: 'email', label: 'email', value: 'foovalidemail.com'},
              { kind: 'text', label: 'name', value: 'Foo Bar' }
            ].to_json
          }
        )
      end

      it {should respond_with 400}

      it "should post an email validation error" do
        expect(response.body).to include('Email inválido')
      end
    end

    context "invalid nome" do
      before do 
        post(
          :create,
          mobilization_id: widget.mobilization.id,
          format: :json,
          form_entry: {
            widget_id: widget.id,
            fields: [
              { kind: 'email', label: 'email', value: 'foo@validemail.com' },
              { kind: 'text', label: 'name', value: 'Lu' }
            ].to_json
          }
        )
      end

      it {should respond_with 400}

      it "should post an email validation error" do
        expect(response.body).to include('Campo é pequeno demais.')
      end
    end


    [
      {
        field_name: 'email',
        field_type: 'email',
        field_value: 'foo@validemail.com',
        message_retrieved: 'Campo não pode estar vazio'
      },
      {
        field_name: 'first name',
        field_type: 'text',
        field_value: 'Jão',
        message_retrieved: 'Email inválido'
      }
    ].each do |dados|
      context "missing #{dados[:field_name]}" do
        before do 
          post(
            :create,
            mobilization_id: widget.mobilization.id,
            format: :json,
            form_entry: {
              widget_id: widget.id,
              fields: [{kind: dados[:field_type], label: dados[:field_name], value: dados[:field_value]}].to_json
            }
          )
        end

        it {should respond_with 200}

        it "should not return a(an) #{dados[:field_name]} validation error" do
          expect(response.body).not_to include(dados[:message_retrieved])
        end
      end
    end  
  end
end
