# coding: utf-8
require 'rails_helper'

RSpec.describe Widget, type: :model do
  it { should belong_to :block }

  it { should validate_presence_of :sm_size }
  it { should validate_presence_of :md_size }
  it { should validate_presence_of :lg_size }

  it { should validate_presence_of :kind }
  it { should validate_uniqueness_of :mailchimp_segment_id }

  it { should have_one :mobilization }
  it { should have_one :community }

  it { should have_many :form_entries }
  it { should have_many :donations }
  it { should have_many :matches }
  it { should have_many :activist_pressures }

  describe 'default_scope' do
    let!(:deleted_1) { create(:widget, deleted_at: DateTime.now) }
    let!(:deleted_2) { create(:widget, deleted_at: DateTime.now) }
    let!(:deleted_3) { create(:widget, deleted_at: DateTime.now) }
    let!(:widget_1) { create(:widget, deleted_at: nil) }
    let!(:widget_2) { create(:widget, deleted_at: nil) }
    let!(:widget_3) { create(:widget, deleted_at: nil) }

    subject { Widget.all }

    it 'deleted widget should not be returned' do
      expect(subject).to_not include(deleted_1)
      expect(subject).to_not include(deleted_2)
      expect(subject).to_not include(deleted_3)
    end

    it 'widgets not deleted should be returned' do
      expect(subject).to include(widget_1)
      expect(subject).to include(widget_2)
      expect(subject).to include(widget_3)
    end
  end


  describe "#segment_name" do
    context "Regular form" do
      it "should set a segment name" do
        widget = Widget.make! kind: 'form'
        expect(widget.segment_name).to eq "M#{widget.block.mobilization.id}F#{widget.id} - #{widget.block.mobilization.name[0..89]}"
      end

      it "should set a segment name" do
        widget = Widget.make! kind: 'pressure'
        expect(widget.segment_name).to eq "M#{widget.block.mobilization.id}P#{widget.id} - #{widget.block.mobilization.name[0..89]}"
      end

      it "should set a segment name" do
        widget = Widget.make! kind: 'match'
        expect(widget.segment_name).to eq "M#{widget.block.mobilization.id}M#{widget.id} - #{widget.block.mobilization.name[0..89]}"
      end

      context 'kind: donation' do
        let!(:widget) { Widget.make! kind: 'donation' }

        it { expect(widget.segment_name).to eq "M#{widget.block.mobilization.id}D#{widget.id} - #{widget.block.mobilization.name[0..89]}" }
        it { expect(widget.segment_name donation_segment_kind: :unique).to eq "M#{widget.block.mobilization.id}D#{widget.id} - Única Paga - #{widget.block.mobilization.name[0..89]}" }
        it { expect(widget.segment_name donation_segment_kind: :recurring_active).to eq "M#{widget.block.mobilization.id}D#{widget.id} - Recorrente Ativa - #{widget.block.mobilization.name[0..89]}" }
        it { expect(widget.segment_name donation_segment_kind: :recurring_inactive).to eq "M#{widget.block.mobilization.id}D#{widget.id} - Recorrente Inativa - #{widget.block.mobilization.name[0..89]}" }
      end

      it "should set a segment name" do
        widget = Widget.make! kind: 'draft'
        expect(widget.segment_name).to eq "M#{widget.block.mobilization.id}A#{widget.id} - #{widget.block.mobilization.name[0..89]}"
      end
    end

    context "Action Community form" do
      it "should set a different segment name from a regular widget" do
        widget = Widget.make! kind: 'form', action_community: true
        expect(widget.segment_name).to eq "M#{widget.block.mobilization.id}C#{widget.id} - [Comunidade] #{widget.block.mobilization.name[0..89]}"
      end
    end
  end

  describe '#segment' do
    it 'should handle at least 500 emails' do
      @widget = Widget.make!
      # Generate emails
      generated_emails = 'Pression tests from OurCities Gang <meuemail@lutas.sao.nossas.org>'
      (2..500).each do  |idx|
        generated_emails += ";Pression tests from OurCities Gang #{idx} <meuemail#{idx}@lutas.sao.nossas.org>"
      end
      # Put on widget
      @widget.settings = %/"{
        "title_text":"Stopping legal salary increases from judiciary",
        "main_color":"#757ef1",
        "button_text":"fighting to an end",
        "count_text":"pressures made",
        "show_counter":"true",
        "reply_email":"foo@bar.com",
        "pressure_subject":"Teste - Pelo fim do aumento no judiciário",
        "pressure_body":"Let'a stop with this $@#%! piece of @#%@#@#@ !!!!",
        "targets": #{generated_emails}
      }/

      ret = @widget.save
      expect(ret).to be true
    end
  end

  context "create Widget from TemplateWidget object" do
    before do 
      @template = TemplateWidget.make!
      @block = Block.make!
    end
    subject {
      Widget.create_from(@template, @block)
    }

    it "should place the correctly the block instance" do
      expect(subject.block).to eq(@block)
    end

    it "should copy the settings value" do
      expect(subject.settings).to eq(@template.settings)
    end

    it "should copy the kind value" do
      expect(subject.kind).to eq(@template.kind)
    end

    it "should copy the sm_size value" do
      expect(subject.sm_size).to eq(@template.sm_size)
    end

    it "should copy the md_size value" do
      expect(subject.md_size).to eq(@template.md_size)
    end

    it "should copy the lg_size value" do
      expect(subject.lg_size).to eq(@template.lg_size)
    end

    it "should copy the action_community value" do
      expect(subject.action_community).to eq(@template.action_community)
    end

    it "should copy the exported_at value" do
      expect(subject.exported_at).to eq(@template.exported_at)
    end
  end

  describe '#pressure?' do
    it 'should return true' do
      expect((Widget.new kind: 'pressure').pressure?).to be true
    end
    it 'should return false' do
      expect((Widget.new kind: 'match').pressure?).to be false
      expect((Widget.new kind: 'donation').pressure?).to be false
      expect((Widget.new kind: 'form').pressure?).to be false 
      expect((Widget.new kind: 'draft').pressure?).to be false 
      expect((Widget.new kind: 'content').synchro_to_mailchimp?).to be false
    end
  end

  describe '#match?' do
    it 'should return true' do
      expect((Widget.new kind: 'match').match?).to be true
    end
    it 'should return false' do
      expect((Widget.new kind: 'donation').match?).to be false
      expect((Widget.new kind: 'form').match?).to be false 
      expect((Widget.new kind: 'draft').match?).to be false 
      expect((Widget.new kind: 'content').synchro_to_mailchimp?).to be false
      expect((Widget.new kind: 'pressure').match?).to be false
    end
  end

  describe '#donation?' do
    it 'should return true' do
      expect((Widget.new kind: 'donation').donation?).to be true
    end
    it 'should return false' do
      expect((Widget.new kind: 'form').donation?).to be false 
      expect((Widget.new kind: 'draft').donation?).to be false 
      expect((Widget.new kind: 'content').synchro_to_mailchimp?).to be false
      expect((Widget.new kind: 'pressure').donation?).to be false
      expect((Widget.new kind: 'match').donation?).to be false
    end
  end

  describe '#form?' do
    it 'should return true' do
      expect((Widget.new kind: 'form').form?).to be true
    end
    it 'should return false' do
      expect((Widget.new kind: 'draft').form?).to be false 
      expect((Widget.new kind: 'content').synchro_to_mailchimp?).to be false
      expect((Widget.new kind: 'pressure').form?).to be false
      expect((Widget.new kind: 'match').form?).to be false
      expect((Widget.new kind: 'donation').form?).to be false 
    end
  end

  describe '#synchro_to_mailchimp?' do
    it 'should return true' do
      expect((Widget.new kind: 'form').synchro_to_mailchimp?).to be true
      expect((Widget.new kind: 'pressure').synchro_to_mailchimp?).to be true
      expect((Widget.new kind: 'match').synchro_to_mailchimp?).to be true
      expect((Widget.new kind: 'donation').synchro_to_mailchimp?).to be true
    end
    it 'should return false' do
      expect((Widget.new kind: 'content').synchro_to_mailchimp?).to be false
      expect((Widget.new kind: 'draft').synchro_to_mailchimp?).to be false
    end
  end

  describe '#create_mailchimp_donators_segments' do
    let(:widget) { create :widget, mailchimp_unique_segment_id: nil }

    it do 
      obj = spy :segment_data
      allow(obj).to receive(:body).and_return({"id" => 12})
      allow(widget).to receive(:create_segment).and_return obj

      widget.create_mailchimp_donators_segments

      expect(widget).to have_received(:create_segment).exactly(3).times
    end
  end

  describe 'resync_all' do
    let(:widget) { create(:widget) }
    let!(:form_entry) { create(:form_entry, widget: widget)}
    let!(:donation) { create(:donation, widget: widget)}
    let!(:activist_pressure) { create(:activist_pressure, widget: widget)}

    before do
      expect_any_instance_of(FormEntry).to receive(:async_update_mailchimp)
      expect_any_instance_of(Donation).to receive(:async_update_mailchimp)
      expect_any_instance_of(ActivistPressure).to receive(:async_update_mailchimp)
    end

    it 'should call async mailchimp update on related entities' do
      widget.resync_all
    end
  end
end
