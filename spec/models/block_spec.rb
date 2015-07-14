require 'rails_helper'

RSpec.describe Block, type: :model do
  describe "asociations" do
    it{ is_expected.to belong_to :mobilization }
  end

  describe "validations" do
    it{ is_expected.to validate_presence_of :mobilization_id }
  end
end
