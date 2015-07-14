require 'rails_helper'

RSpec.describe Mobilization, type: :model do
  it { should belong_to :user }
  it { should have_many :blocks }
  it { should validate_presence_of :user_id }
end
