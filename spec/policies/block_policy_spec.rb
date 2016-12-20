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
  end

  context "for a user in community's list" do
    let(:user) { User.make! }
    let(:block) { Block.make! }
    subject { described_class.new(user, block) }

    before { CommunityUser.create! user_id: user.id, community_id: block.community.id, role: 1 }

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

  context "for a admin user" do
    subject { described_class.new((User.make! admin: true), Block.make!) }
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
