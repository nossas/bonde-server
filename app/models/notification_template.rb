class NotificationTemplate < ActiveRecord::Base
  belongs_to :community
  validates :subject_template, :body_template, :label, presence: true
end
