require 'rails_helper'

RSpec.describe BlockPolicy do
  context "for a visitor" do
    subject { described_class.new(nil, Block.make!) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should_not allows(:create) }
    it { should_not allows(:new) }
    it { should_not allows(:update) }
    it { should_not allows(:edit) }
    it { should_not allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Block
    end
    it "should return empty permitted attributes" do
      expect(subject.permitted_attributes).to eq []
    end
  end

  context "for a non-owner user" do
    subject { described_class.new(User.make!, Block.make!) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should allows(:create) }
    it { should allows(:new) }
    it { should_not allows(:update) }
    it { should_not allows(:edit) }
    it { should_not allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Block
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq [
        :position, :bg_class, :bg_image, :hidden, :name, :menu_hidden,
        widgets_attributes: [:kind, :sm_size, :md_size, :lg_size]
      ]
    end
  end

  context "for the owner" do
    let(:user) { User.make! }
    let(:mobilization) { Mobilization.make! user: user }
    subject { described_class.new(user, Block.make!(mobilization: mobilization)) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should allows(:create) }
    it { should allows(:new) }
    it { should allows(:update) }
    it { should allows(:edit) }
    it { should allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Block
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq [
        :position, :bg_class, :bg_image, :hidden, :name, :menu_hidden,
        widgets_attributes: [:kind, :sm_size, :md_size, :lg_size]
      ]
    end
  end
end
