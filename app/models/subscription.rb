class Subscription < ActiveRecord::Base
  belongs_to :widget
  belongs_to :activist
  belongs_to :community

  has_many :donations, foreign_key: :local_subscription_id

  validates :widget, :activist, :community, :amount, presence: true

  def next_transaction_charge_date
    if last_charge
      return (last_charge.created_at + 1.month)
    end

    DateTime.now
  end

  def last_charge
    @last_charge ||= donations.paid.ordered.first
  end

end
