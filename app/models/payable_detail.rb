class PayableDetail < ActiveRecord::Base
  self.primary_key = 'payable_id'
  self.table_name = 'public.payable_details'

  belongs_to :organization
  default_scope { order('transaction_id desc') }
  scope :by_widget, ->(id) { where(widget_id: id) }
  scope :by_mobilization, ->(id) { where(mobilization_id: id) }
  scope :by_block, ->(id) { where(block_id: id) }

  def readonly?
    true
  end
end
