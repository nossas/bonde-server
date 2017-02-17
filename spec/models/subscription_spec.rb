require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it { should belong_to :widget }
  it { should belong_to :activist }
  it { should belong_to :community }

  it { should have_many :donations }
end
