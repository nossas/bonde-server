class Notification < ActiveRecord::Base
  belongs_to :activist
  belongs_to :notification_template

  validates :activist, :notification_template, presence: true
end
