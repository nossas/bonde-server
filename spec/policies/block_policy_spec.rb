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
        widgets_attributes: [:kind, :sm_size, :md_size, :lg_size, settings: [
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
        ]]
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
        widgets_attributes: [:kind, :sm_size, :md_size, :lg_size, settings: [
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
        ]]
      ]
    end
  end
end
