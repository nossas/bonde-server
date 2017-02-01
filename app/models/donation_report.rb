class DonationReport < ActiveRecord::Base
  acts_as_copy_target
  self.primary_key = 'id'
  self.table_name = 'public.donation_reports'

  belongs_to :community
  belongs_to :donation, foreign_key: :id

  scope :by_widget, ->(id) { where(widget_id: id) }
  scope :by_mobilization, ->(id) { where(mobilization_id: id) }

  def readonly?
    true
  end
end
