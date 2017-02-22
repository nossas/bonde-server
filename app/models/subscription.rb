class Subscription < ActiveRecord::Base
  belongs_to :widget
  belongs_to :activist
  belongs_to :community

  has_many :donations, foreign_key: :local_subscription_id

  validates :widget, :activist, :community, :amount, presence: true

  def last_charge
    @last_charge ||= donations.paid.ordered.first
  end

end
