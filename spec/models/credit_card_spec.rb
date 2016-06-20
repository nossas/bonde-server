require 'rails_helper'

RSpec.describe CreditCard, type: :model do
  it { should belong_to :activist }
end
