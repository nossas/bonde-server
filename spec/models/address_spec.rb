require 'rails_helper'

RSpec.describe Address, type: :model do
  it { should belong_to :activist }
end
