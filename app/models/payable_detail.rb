class PayableDetail < ActiveRecord::Base
  belongs_to :organization
  default_scope { order('transaction_id desc') }
  scope :by_widget, ->(id) { where(widget_id: id) }
  scope :by_mobilization, ->(id) { where(mobilization_id: id) }
  scope :by_block, ->(id) { where(block_id: id) }

  def self.table_name
    'public.payable_details'
  end

  def readonly?
    true
  end
end
