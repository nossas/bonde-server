require 'rails_helper'

RSpec.describe FormEntry, type: :model do
  it { should belong_to :widget }
  it { should validate_presence_of :fields }
  it { should validate_presence_of :widget }
end
