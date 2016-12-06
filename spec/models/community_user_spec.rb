require 'rails_helper'

RSpec.describe CommunityUser, type: :model do
  it { should validate_presence_of :user }
  it { should validate_presence_of :community }
  it { should validate_presence_of :role }
end
