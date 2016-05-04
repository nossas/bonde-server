require 'rails_helper'

RSpec.describe DonationPolicy do
  before do
    allow_any_instance_of(Donation).to receive(:create_transaction)
  end

  context "for a visitor" do
    subject { described_class.new(nil, Donation.make!) }
    it { should allow(:create) }

    it "should have complete scope" do
      expect(subject.scope).to eq Donation
    end

    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq [:widget_id, :payment_method, :amount, :email, :card_hash, :customer]
    end
  end

  context "for a user" do
    subject { described_class.new(User.make!, Donation.make!) }
    it { should allow(:create) }

    it "should have complete scope" do
      expect(subject.scope).to eq Donation
    end

    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq [:widget_id, :payment_method, :amount, :email, :card_hash, :customer]
    end
  end
end
