require 'rails_helper'

RSpec.describe ActivistPressurePolicy do
  context "for a user" do
    subject { described_class.new(User.make!, ActivistPressure.make!) }
    it { should allow(:create) }
    it "should have complete scope" do
      expect(subject.scope).to eq ActivistPressure
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq [:widget_id, :activist_id, :firstname, :lastname]
    end
  end
end
