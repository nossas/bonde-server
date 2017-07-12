require 'rails_helper'

RSpec.describe WidgetPolicy do

  permitted_attributes = [:kind, settings: [
    # Can re-use settings
    # Autofire config
    :email_text,
    :email_subject,
    :sender_name,
    :sender_email,

    # Generic widget config
    :title_text,
    :main_color,
    :button_text,
    :count_text,
    :show_counter,

    # Settings specific widget
    :whatsapp_text,

    # Content Widget
    :content,

    # Pressure Widget
    :targets,
    :pressure_subject,
    :pressure_body,
    :reply_email,
    :show_city,

    # Donation widget
    :default_donation_value,
    :donation_value1,
    :donation_value2,
    :donation_value3,
    :donation_value4,
    :donation_value5,
    :recurring_period,
    :payment_type,
    :payment_methods,
    :customer_data,

    # Match Widget
    :choicesA,
    :choices1,
    :labelChoices1,
    :labelChoicesA,

    :call_to_action,
    :action_community,

    #finish messages
    :finish_message,
    :finish_message_type,
    :finish_message_background
    ]
  ]

  context "for a visitor" do
    subject { described_class.new(nil, Widget.make!) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should_not allows(:create) }
    it { should_not allows(:new) }
    it { should_not allows(:update) }
    it { should_not allows(:edit) }
    it { should_not allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Widget
    end
    it "should return empty permitted attributes" do
      expect(subject.permitted_attributes).to eq []
    end
  end

  context "for a non-owner user" do
    subject { described_class.new(User.make!, Widget.make!) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should allows(:create) }
    it { should allows(:new) }
    it { should_not allows(:update) }
    it { should_not allows(:edit) }
    it { should_not allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Widget
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq permitted_attributes
    end
  end

  context "for a user in Community's list" do
    let(:user) { User.make! admin: true }
    let(:mobilization) { Mobilization.make! user: user }
    let(:block) { Block.make! mobilization: mobilization }
    subject { described_class.new(user, Widget.make!(block: block)) }

    before { CommunityUser.create! user_id: user.id, community_id: mobilization.community.id, role: 1}

    it { should allows(:index) }
    it { should allows(:show) }
    it { should allows(:create) }
    it { should allows(:new) }
    it { should allows(:update) }
    it { should allows(:edit) }
    it { should allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Widget
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq permitted_attributes
    end
  end

  context "for an admin" do
    let(:user) { User.make! admin: true }
    let(:mobilization) { Mobilization.make! user: user }
    let(:block) { Block.make! mobilization: mobilization }
    subject { described_class.new(user, Widget.make!(block: block)) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should allows(:create) }
    it { should allows(:new) }
    it { should allows(:update) }
    it { should allows(:edit) }
    it { should allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Widget
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq permitted_attributes
    end
  end

  context "for the owner" do
    let(:user) { User.make! }
    let(:mobilization) { Mobilization.make! user: user }
    let(:block) { Block.make! mobilization: mobilization }
    subject { described_class.new(user, Widget.make!(block: block)) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should allows(:create) }
    it { should allows(:new) }
    it { should allows(:update) }
    it { should allows(:edit) }
    it { should allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Widget
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq permitted_attributes
    end
  end
end
