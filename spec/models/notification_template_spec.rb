require 'rails_helper'

RSpec.describe NotificationTemplate, type: :model do
  it { should belong_to :community}
  it { should validate_presence_of :label }
  it { should validate_presence_of :subject_template }
  it { should validate_presence_of :body_template }

end
