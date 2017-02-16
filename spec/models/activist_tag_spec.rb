require 'rails_helper'

RSpec.describe ActivistTag, type: :model do
  subject { build(:activist_tag) }

  it { should belong_to :activist }
  it { should belong_to :community }

  it { should validate_presence_of(:activist) }
  it { should validate_presence_of(:community) }
end
