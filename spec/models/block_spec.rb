require 'rails_helper'

RSpec.describe Block, type: :model do
  it { should belong_to :mobilization }
  it { should validate_presence_of :mobilization_id }
end
