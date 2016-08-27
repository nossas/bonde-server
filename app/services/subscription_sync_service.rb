require 'pagarme'

class SubscriptionSyncService
  # class method
  def self.sync(subscription_id)
    self.new(subscription_id).sync
  end

  def initialize(subscription_id)
    @subscription = PagarMe::Subscription.find_by_id(subscription_id)
    @parent_donation = Donation.find @subscription.metadata['donation_id']
  end

  def sync
    # TODO: thie unless, fixes weird missing transaction_id and status on donation
    unless @parent_donation.transaction_id.present?
      payment = @parent_donation.payments.first
      @parent_donation.update_attributes(
        transaction_id: payment.transaction_id,
        transaction_status: payment.transaction_status,
      )
    end
    @subscription.transactions.each do |transaction|
      if donation = Donation.find_by_transaction_id(transaction.id)
        next if donation.status == transaction.status
        donation.update_attribute(:transaction_status, transaction.status)
      else
        Donation.create(
          transaction_id: transaction.id,
          amount: @parent_donation.amount,
          activist_id: @parent_donation.activist_id,
          transaction_status: transaction.status,
          widget_id: @parent_donation.widget_id,
          subscription_id: @subscription.id,
          subscription: true,
          skip: true,
          period: @parent_donation.period,
          plan_id: @parent_donation.plan_id,
          email: @parent_donation.email,
          payment_method: @parent_donation.payment_method,
          parent_id: @parent_donation.id,
          created_at: transaction.date_created
        )
      end
    end
  end
end
