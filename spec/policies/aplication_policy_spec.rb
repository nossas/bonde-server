require 'rails_helper'

RSpec.describe ApplicationPolicy do
  context "for a visitor" do
    subject { described_class.new(nil, Mobilization.make!) }
    it { should allow(:index) }
    it { should allow(:show) }
    it { should_not allow(:create) }
    it { should_not allow(:new) }
    it { should_not allow(:update) }
    it { should_not allow(:edit) }
    it { should_not allow(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Mobilization
    end
  end

  context "for a non-owner user" do
    subject { described_class.new(User.make!, Mobilization.make!) }
    it { should allow(:index) }
    it { should allow(:show) }
    it { should allow(:create) }
    it { should allow(:new) }
    it { should_not allow(:update) }
    it { should_not allow(:edit) }
    it { should_not allow(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Mobilization
    end
  end

  context "for the owner" do
    let(:user) { User.make! }
    subject { described_class.new(user, Mobilization.make!(user: user)) }
    it { should allow(:index) }
    it { should allow(:show) }
    it { should allow(:create) }
    it { should allow(:new) }
    it { should allow(:update) }
    it { should allow(:edit) }
    it { should allow(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Mobilization
    end
  end
end
