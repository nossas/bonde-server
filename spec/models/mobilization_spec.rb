require 'rails_helper'

RSpec.describe Mobilization, type: :model do
  describe "asociations" do
    it{ is_expected.to belong_to :user }
    it{ is_expected.to have_many :blocks }
  end

  describe "validations" do
    it{ is_expected.to validate_presence_of :user_id }
  end
end
