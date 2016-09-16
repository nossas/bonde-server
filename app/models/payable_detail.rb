class PayableDetail < ActiveRecord::Base
  belongs_to :organization
  default_scope { order('transaction_id desc') }
  def self.table_name
    'public.payable_details'
  end

  def readonly?
    true
  end
end
