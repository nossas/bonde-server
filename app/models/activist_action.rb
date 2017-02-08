class ActivistAction < ActiveRecord::Base
  self.primary_key = 'activist_id'
  self.table_name = 'public.activist_actions'

  belongs_to :community
end
