class CreditCard < ActiveRecord::Base
  belongs_to :activist

  validates :activist, presence: true
end
