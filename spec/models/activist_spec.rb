require 'rails_helper'

RSpec.describe Activist, type: :model do
  it { should have_many :donations }
  it { should have_many :addresses }
  it { should have_many :credit_cards }
end
