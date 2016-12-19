require 'rails_helper'

RSpec.describe Community, type: :model do
  it { should validate_presence_of :name }
  
  it { should have_many :payable_transfers }
  it { should have_many :payable_details }
  it { should have_many :mobilizations }
  it { should have_many :community_users }
  it { should have_many :users }

  it { should validate_uniqueness_of :name }
end
