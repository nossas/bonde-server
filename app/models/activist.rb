class Activist < ActiveRecord::Base
  has_many :credit_cards
  has_many :donations
  has_many :addresses
end
