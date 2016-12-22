class Activist < ActiveRecord::Base
  has_many :donations
  has_many :credit_cards, dependent: :destroy
  has_many :addresses, dependent: :destroy

  validates :name, :email, presence: true
  validates :name, length: { in: 3..70 }
  validates_format_of :email, with: Devise.email_regexp
end
