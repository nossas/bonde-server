class PayableDetail < ActiveRecord::Base
  self.primary_key = 'payable_id'
  self.table_name = 'public.payable_details'

  belongs_to :organization
  belongs_to :donation
  default_scope { order('transaction_id desc') }
  scope :by_widget, ->(id) { where(widget_id: id) }
  scope :by_mobilization, ->(id) { where(mobilization_id: id) }
  scope :by_block, ->(id) { where(block_id: id) }
  scope :from_subscription, -> { where('payable_details.subscription_id is not null')}
  scope :without_transfer, -> { where(payable_transfer_id: nil) }
  scope :is_paid, -> { where(payable_status: 'paid')}
  scope :over_limit_to_transfer, -> { without_transfer.where('payable_details.payable_date <= now()')}

  def readonly?
    true
  end
end
