require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { should belong_to :activist}
  it { should belong_to :notification_template}
  it { should validate_presence_of :activist}
  it { should validate_presence_of :notification_template }
end
