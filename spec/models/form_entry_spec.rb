require 'rails_helper'

RSpec.describe FormEntry, type: :model do
  let(:activist) { Activist.make! }
  let(:build_form_entry) { FormEntry.make }
  let(:email) { nil }

  it { should belong_to :widget }
  it { should belong_to :activist }

  it { should validate_presence_of :fields }
  it { should validate_presence_of :widget }

  before do
    allow(build_form_entry).to receive(:email).and_return(email)
    allow(build_form_entry).to receive(:first_name).and_return('Foo bar')
  end

  describe '#link_activist' do
    let(:email) { activist.email }
    subject { build_form_entry.link_activist }

    context 'when activist exists' do
      it 'should link with found activist' do
        expect(Activist).to receive(:by_email).with(activist.email).and_call_original
        subject
        expect(build_form_entry.activist).to eq(activist)
      end
    end

    context 'when activist does not exists' do
      let(:email) { 'loem@lorem.com' }

      it 'should build a new activist' do
        expect(build_form_entry).to receive(:create_activist).with(name: 'Foo bar', email: email).and_call_original
        subject
        expect(build_form_entry.activist).to_not be_nil
        expect(build_form_entry.activist).to_not eq(activist)
      end
    end
  end

  describe "before create" do
    let(:email) { 'loem@lorem.com' }
    it 'should call link_activist' do
      expect(build_form_entry).to receive(:link_activist)
      build_form_entry.save
    end
  end

  describe "Puts a message in Resque queue" do
    before do
      Resque.redis.flushall
      @form_entry=FormEntry.new id:25
    end

    it "should save data in redis" do
      @form_entry.async_send_to_mailchimp

      resque_job = Resque.peek(:mailchimp_synchro)
      expect(resque_job).to be_present
    end

    it "test the arguments" do
      @form_entry.async_send_to_mailchimp

      resque_job = Resque.peek(:mailchimp_synchro)
      expect(resque_job['args'][0]).to be 25
      expect(resque_job['args'][1]).to be_eql 'formEntry'
      expect(resque_job['args'].size).to be 2
    end
  end

  describe 'fields translating' do
    context 'with data' do 
      def campos
        [
          {
            'uid': 'field-1448381355384-46', 
            'kind': 'text',
            'label': 'Nome',
            'placeholder': 'Insira aqui seu primeiro nome',
            'required': 'true',
            'value': 'José'
          },
          {
            'uid': 'field-1448381377063-15',
            'kind': 'text',
            'label': 'Sobrenome',
            'placeholder': 'Insira aqui seu último sobrenome',
            'required': 'true',
            'value': 'Manuel'
          },
          {
            'uid': 'field-1448381397174-71',
            'kind': 'email',
            'label': 'Email',
            'placeholder': 'Insira aqui o seu email',
            'required': 'true',
            'value': 'zemane@naoexiste.com'
          },
          {
            'uid': 'field-2313463424234-41',
            'kind': 'text',
            'label': 'Celular',
            'placeholder': 'Insira aqui o seu telefone',
            'required': 'true',
            'value': '(12) 36121-1234'
          },
          {
            'uid': 'field-2346134634541-76',
            'kind': 'text',
            'label': 'Cidade',
            'placeholder': 'Insira aqui o seu cidade',
            'required': 'true',
            'value': 'Pindallas'
          }
        ]      
      end

      let(:form_entry) { FormEntry.new fields: campos.to_json }

      it '#first_name' do 
        expect(form_entry.first_name).to eq('José')
      end

      it '#last_name' do 
        expect(form_entry.last_name).to eq('Manuel')
      end

      it '#email' do 
        expect(form_entry.email).to eq('zemane@naoexiste.com')
      end

      it '#phone' do 
        expect(form_entry.phone).to eq('(12) 36121-1234')
      end

      it '#city' do 
        expect(form_entry.city).to eq('Pindallas')
      end
    end

    context 'with data without fields' do 
      let(:form_entry) { FormEntry.new fields: '[ ]' }

      it '#first_name' do 
        expect(form_entry.first_name).not_to be
      end

      it '#last_name' do 
        expect(form_entry.last_name).not_to be
      end

      it '#email' do 
        expect(form_entry.email).not_to be
      end

      it '#phne' do 
        expect(form_entry.phone).not_to be
      end

      it '#city' do 
        expect(form_entry.city).not_to be
      end
    end

    context 'empty fields' do 
      let(:form_entry) { FormEntry.new }

      it '#first_name' do 
        expect(form_entry.first_name).not_to be
      end

      it '#last_name' do 
        expect(form_entry.last_name).not_to be
      end

      it '#email' do 
        expect(form_entry.email).not_to be
      end

      it '#phne' do 
        expect(form_entry.phone).not_to be
      end

      it '#city' do 
        expect(form_entry.city).not_to be
      end
    end
  end
end

