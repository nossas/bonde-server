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
    # Content Widget
    :content,

    # Pressure Widget
    :targets,
    :pressure_subject,
    :pressure_body,

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
    :action_community
    ]
  ]

  context "for a visitor" do
    subject { described_class.new(nil, Widget.make!) }
    it { should allow(:index) }
    it { should allow(:show) }
    it { should_not allow(:create) }
    it { should_not allow(:new) }
    it { should_not allow(:update) }
    it { should_not allow(:edit) }
    it { should_not allow(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Widget
    end
    it "should return empty permitted attributes" do
      expect(subject.permitted_attributes).to eq []
    end
  end

  context "for a non-owner user" do
    subject { described_class.new(User.make!, Widget.make!) }
    it { should allow(:index) }
    it { should allow(:show) }
    it { should allow(:create) }
    it { should allow(:new) }
    it { should_not allow(:update) }
    it { should_not allow(:edit) }
    it { should_not allow(:destroy) }
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
    it { should allow(:index) }
    it { should allow(:show) }
    it { should allow(:create) }
    it { should allow(:new) }
    it { should allow(:update) }
    it { should allow(:edit) }
    it { should allow(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Widget
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq permitted_attributes
    end
  end
end
