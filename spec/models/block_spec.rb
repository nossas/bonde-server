require 'rails_helper'

RSpec.describe Block, type: :model do
  it { should belong_to :mobilization }
  it { should have_many :widgets }
  it { should validate_presence_of :mobilization_id }
  it { should validate_presence_of :position }
  it { should accept_nested_attributes_for :widgets }

  describe '.not_deleted' do
    context 'should not list blocks that has deleted' do
      let!(:block_deleted) { create(:block, deleted_at: DateTime.now)}
      let!(:block) { create(:block) }

      subject { Block.not_deleted }

      it 'should not include deleted' do
        expect(subject).to_not include(block_deleted)
      end
    end
  end

  describe "#set_position" do
    it "should set the block's position to the maximum position + 1" do
      mobilization1 = Mobilization.make!
      mobilization2 = Mobilization.make!
      block1 = Block.make! mobilization: mobilization1
      block2 = Block.make! mobilization: mobilization1
      block3 = Block.make! mobilization: mobilization2
      block4 = Block.make! mobilization: mobilization2, position: 123
      block5 = Block.make! mobilization: mobilization2
      expect(block1.position).to eq 1
      expect(block2.position).to eq 2
      expect(block3.position).to eq 1
      expect(block4.position).to eq 123
      expect(block5.position).to eq 124
    end
  end

  context "create block from TemplateBlock object" do
    before do
      @template = TemplateBlock.make!
      @mobilization = Mobilization.make!
    end
    subject {
      Block.create_from(@template, @mobilization)
    }

    it "should place the correctly the mobilization instance" do
      expect(subject.mobilization).to eq(@mobilization)
    end

    it "should copy the bg_class value" do
      expect(subject.bg_class).to eq(@template.bg_class)
    end

    it "should copy the position value" do
      expect(subject.position).to eq(@template.position)
    end

    it "should copy the hidden value" do
      expect(subject.hidden).to eq(@template.hidden)
    end

    it "should copy the bg_image value" do
      expect(subject.bg_image).to eq(@template.bg_image)
    end

    it "should copy the name value" do
      expect(subject.name).to eq(@template.name)
    end

    it "should copy the menu_hidden value" do
      expect(subject.menu_hidden).to eq(@template.menu_hidden)
    end
  end
end
