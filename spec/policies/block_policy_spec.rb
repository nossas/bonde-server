require 'rails_helper'

RSpec.describe BlockPolicy do
  context "for a visitor" do
    subject { described_class.new(nil, Block.make!) }
    it { should allow(:index) }
    it { should allow(:show) }
    it { should_not allow(:create) }
    it { should_not allow(:new) }
    it { should_not allow(:update) }
    it { should_not allow(:edit) }
    it { should_not allow(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Block
    end
    it "should return empty permitted attributes" do
      expect(subject.permitted_attributes).to eq []
    end
  end

  context "for a non-owner user" do
    subject { described_class.new(User.make!, Block.make!) }
    it { should allow(:index) }
    it { should allow(:show) }
    it { should allow(:create) }
    it { should allow(:new) }
    it { should_not allow(:update) }
    it { should_not allow(:edit) }
    it { should_not allow(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Block
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq [:position, :bg_class, :bg_image, :hidden, :name, widgets_attributes: [:kind, :sm_size, :md_size, :lg_size]]
    end
  end

  context "for the owner" do
    let(:user) { User.make! }
    let(:mobilization) { Mobilization.make! user: user }
    subject { described_class.new(user, Block.make!(mobilization: mobilization)) }
    it { should allow(:index) }
    it { should allow(:show) }
    it { should allow(:create) }
    it { should allow(:new) }
    it { should allow(:update) }
    it { should allow(:edit) }
    it { should allow(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Block
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq [:position, :bg_class, :bg_image, :hidden, :name, widgets_attributes: [:kind, :sm_size, :md_size, :lg_size]]
    end
  end
end
