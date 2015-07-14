require 'rails_helper'

RSpec.describe Widget, type: :model do
  it { should belong_to :block }
  it { should validate_presence_of :block_id }
  it { should validate_presence_of :size }
  it { should validate_presence_of :kind }
end
