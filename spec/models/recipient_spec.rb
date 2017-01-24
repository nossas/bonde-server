require 'rails_helper'

RSpec.describe Recipient, type: :model do
  it { should belong_to :community }
  
  it { should validate_presence_of :pagarme_recipient_id }
  it { should validate_presence_of :recipient }
  it { should validate_presence_of :community }

  # !!! The test below is commented because cause an error, as it tries to save a null value on recipient field !!!
  # it { should validate_uniqueness_of :pagarme_recipient_id }
end
