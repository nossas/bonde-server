require 'rails_helper'

RSpec.describe Block, type: :model do
  it { should belong_to :mobilization }
  it { should have_many :widgets }
  it { should validate_presence_of :mobilization_id }
  it { should validate_presence_of :position }
  it { should accept_nested_attributes_for :widgets }

  describe "#set_position" do
    it "should set the block's position" do
      mobilization1 = Mobilization.make!
      mobilization2 = Mobilization.make!
      block1 = Block.make! mobilization: mobilization1
      block2 = Block.make! mobilization: mobilization1
      block3 = Block.make! mobilization: mobilization2
      expect(block1.position).to eq 1
      expect(block2.position).to eq 2
      expect(block3.position).to eq 1
    end
  end
end
