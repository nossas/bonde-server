class Activist < ActiveRecord::Base
  has_many :credit_cards
  has_many :donations
  has_many :addresses

  before_create :normalize_phone

  def normalize_phone
    self.phone.gsub!(/\D/, '')
  end
end
