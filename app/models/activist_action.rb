class ActivistAction < ActiveRecord::Base
  self.primary_key = 'activist_id'
  self.table_name = 'public.activist_actions'

  belongs_to :community

  scope :by_widget, ->(id) { where(widget_id: id) }
  scope :by_mobilization, ->(id) { where(mobilization_id: id) }
end
