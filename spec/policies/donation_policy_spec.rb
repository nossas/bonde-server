require 'rails_helper'

RSpec.describe DonationPolicy do
  context "for a visitor" do
    subject { described_class.new(nil, Donation.make!) }
    it { should allow(:create) }

    it "should have complete scope" do
      expect(subject.scope).to eq Donation
    end

    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq donation_attributes
    end
  end

  context "for a user" do
    subject { described_class.new(User.make!, Donation.make!) }
    it { should allow(:create) }

    it "should have complete scope" do
      expect(subject.scope).to eq Donation
    end

    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq donation_attributes
    end
  end
end

def donation_attributes
  [:widget_id, :payment_method, :amount, :email, :card_hash, customer: [
    :name,
    :email,
    :document_number,
    phone: [
      :ddd,
      :number
    ],
    address: [
      :zipcode,
      :street,
      :street_number,
      :complementary,
      :neighborhood,
      :city,
      :state
    ]
  ]]
end
