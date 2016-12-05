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
        expect(Activist).to receive(:find_by).with(email: activist.email).and_call_original
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
      @form_entry=FormEntry.make!
    end

    it "should save data in redis" do
      @form_entry.async_send_to_mailchimp

      resque_job = Resque.peek(:mailchimp_synchro)
      expect(resque_job).to be_present		
    end

    it "test the arguments" do
      @form_entry.async_send_to_mailchimp

      resque_job = Resque.peek(:mailchimp_synchro)
      expect(resque_job['args'][1]).to be_eql 'formEntry'
      expect(resque_job['args'].size).to be 2
    end
  end
end

