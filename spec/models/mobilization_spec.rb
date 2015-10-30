require 'rails_helper'

RSpec.describe Mobilization, type: :model do
  it { should belong_to :user }
  it { should have_many :blocks }
  it { should have_many(:widgets).through(:blocks) }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :name }
  it { should validate_presence_of :goal }
  it { should validate_length_of :twitter_share_text }

  context "generate a slug" do
    before do
      @mobilization = Mobilization.create!(name: "mobilization", goal: "change the world", user: User.make!)
    end

    it "should include mobilization's name" do
      expect(@mobilization.slug).to include @mobilization.name.parameterize
    end
  end

  context "set Twitter's share text" do
    subject { Mobilization.create!(name: "mobilization", goal: "change the world", user: User.make!) }

    it "should include mobilization's name" do
      expect(subject.twitter_share_text).to include subject.name
    end
  end
end
