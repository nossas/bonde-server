require 'rails_helper'

RSpec.describe Widget, type: :model do
  it { should belong_to :block }
  it { should validate_presence_of :sm_size }
  it { should validate_presence_of :md_size }
  it { should validate_presence_of :lg_size }
  it { should validate_presence_of :kind }
  it { should validate_uniqueness_of :mailchimp_segment_id }
  it { should have_many :form_entries }

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
end
