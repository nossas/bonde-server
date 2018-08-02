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
      let!(:block) { create(:block, position: 2) }

      subject { Block.not_deleted }

      it 'should not include deleted' do
        expect(subject).to_not include(block_deleted)
      end
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

  describe 'update blocks position' do
    context 'when pass two blocks with new positions' do
      let!(:block1) { create(:block, position: 1) }
      let!(:block2) { create(:block, position: 2) }
      let!(:block3) { create(:block, position: 3) }
      let!(:block4) { create(:block, position: 4) }

      it 'should update  position of blocks' do
        blocks = [] << {"id": block1.id, "position": 2} << {"id": block2.id, "position": 1}
        switch_positions = Block.update_blocks(blocks)
        block1.reload
        block2.reload
        expect(switch_positions[:status]).to eq('success')
        expect(block1.position).to eq(2)
        expect(block2.position).to eq(1)
      end
    end
  end
end
