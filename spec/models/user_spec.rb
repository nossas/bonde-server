require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many :mobilizations }
  it { should validate_presence_of :provider }
  it { should validate_presence_of :uid }
  it { should validate_presence_of :email }
end
