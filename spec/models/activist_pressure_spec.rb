require 'rails_helper'

RSpec.describe ActivistPressure, type: :model do
  it { should belong_to :widget }
  it { should belong_to :activist }
  it { should validate_presence_of :widget }
  it { should validate_presence_of :activist }
  it { should validate_presence_of :activist }
  it { should have_one :block }
  it { should have_one :mobilization }
  it { should have_one :organization }
end
