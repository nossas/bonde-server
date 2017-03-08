require 'rails_helper'

RSpec.describe NotificationTemplate, type: :model do
  it { should belong_to :community}
end
