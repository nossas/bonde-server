require 'rails_helper'

RSpec.describe MobilizationPolicy do
  context "for a visitor" do
    subject { described_class.new(nil, Mobilization.make!) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should_not allows(:create) }
    it { should_not allows(:new) }
    it { should_not allows(:update) }
    it { should_not allows(:edit) }
    it { should_not allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Mobilization
    end
    it "should return empty permitted attributes" do
      expect(subject.permitted_attributes).to eq []
    end
  end

  context "for a non-owner user" do
    subject { described_class.new(User.make!, Mobilization.make!) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should allows(:create) }
    it { should allows(:new) }
    it { should_not allows(:update) }
    it { should_not allows(:edit) }
    it { should_not allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Mobilization
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq %i[
        name
        color_scheme
        google_analytics_code
        goal
        facebook_share_title
        facebook_share_description
        facebook_share_image
        twitter_share_text
        header_font
        body_font
        custom_domain
        slug
        community_id
        tag_list
        favicon
        status
        language
      ]
    end
  end

  context "for the owner" do
    let(:user) { User.make! }
    subject { described_class.new(user, Mobilization.make!(user: user)) }
    it { should allows(:index) }
    it { should allows(:show) }
    it { should allows(:create) }
    it { should allows(:new) }
    it { should allows(:update) }
    it { should allows(:edit) }
    it { should allows(:destroy) }
    it "should have complete scope" do
      expect(subject.scope).to eq Mobilization
    end
    it "should return permitted attributes" do
      expect(subject.permitted_attributes).to eq %i[
        name
        color_scheme
        google_analytics_code
        goal
        facebook_share_title
        facebook_share_description
        facebook_share_image
        twitter_share_text
        header_font
        body_font
        custom_domain
        slug
        community_id
        tag_list
        favicon
        status
        language
      ]
    end
  end
end
