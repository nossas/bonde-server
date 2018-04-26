class SubscriptionReport < ActiveRecord::Base
  acts_as_copy_target
  self.primary_key = 'ID da assinatura'
  self.table_name = 'public.subscription_reports'

  belongs_to :community

  def readonly?
    true
  end
end
