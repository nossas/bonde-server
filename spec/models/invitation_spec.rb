require 'rails_helper'

RSpec.describe Invitation, type: :model do
  subject { build :invitation }

  it { should belong_to :community }
  it { should belong_to :user }

  it { should validate_uniqueness_of(:code).scoped_to(:community_id) }

  it { should validate_presence_of :community_id }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :email }
  it { should validate_presence_of :code }
  it { should validate_presence_of :role }
  it { should validate_presence_of :expires }
  it { should validate_presence_of :expired }

end
