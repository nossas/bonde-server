require 'rails_helper'

RSpec.describe Widget, type: :model do
  it { should belong_to :block }
  it { should validate_presence_of :sm_size }
  it { should validate_presence_of :md_size }
  it { should validate_presence_of :lg_size }
  it { should validate_presence_of :kind }
  it { should validate_uniqueness_of :mailchimp_segment_id }
  it { should have_many :form_entries }
  it { should have_many :donations }

  describe "#segment_name" do
    subject { @widget.segment_name }
    before do
      @widget = Widget.make! kind: 'form'
      @mobilization = @widget.block.mobilization
    end

    context "Regular form" do
      it "should set a segment name" do
        expect(subject).to eq "M#{@mobilization.id}A#{@widget.id} - #{@mobilization.name[0..89]}"
      end
    end

    context "Action Community form" do
      it "should set a different segment name from a regular widget" do
        @widget.update_attribute(:action_community, true)
        expect(subject).not_to eq "M#{@mobilization.id}A#{@widget.id} - #{@mobilization.name[0..89]}"
      end
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

    it "should copy the mailchimp_segment_id value" do
      expect(subject.mailchimp_segment_id).to eq(@template.mailchimp_segment_id)
    end

    it "should copy the action_community value" do
      expect(subject.action_community).to eq(@template.action_community)
    end

    it "should copy the exported_at value" do
      expect(subject.exported_at).to eq(@template.exported_at)
    end
  end
end
