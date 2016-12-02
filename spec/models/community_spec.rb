require 'rails_helper'

RSpec.describe Community, type: :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :city }
  it { should validate_uniqueness_of :name }
  it { should validate_uniqueness_of :city }
end
