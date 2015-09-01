require 'rails_helper'

RSpec.describe FormEntryPolicy do
  context "for a visitor" do
    subject { described_class.new(nil, FormEntry.make!) }
    it { should allow(:create) }
    it "should have complete scope" do
      expect(subject.scope).to eq FormEntry
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq [:widget_id, :fields]
    end
  end

  context "for a user" do
    subject { described_class.new(User.make!, FormEntry.make!) }
    it { should allow(:create) }
    it "should have complete scope" do
      expect(subject.scope).to eq FormEntry
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq [:widget_id, :fields]
    end
  end
end
