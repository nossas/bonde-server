class Activist < ActiveRecord::Base
  has_many :donations
  has_many :credit_cards, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :form_entries
  has_many :activist_pressures
  has_many :activist_matches

  validates :name, :email, presence: true
  validates :name, length: { in: 3..70 }
  validates_format_of :email, with: Devise.email_regexp

  def self.by_email email
    self.where("lower(email) = lower(?)", email).order(id: :asc).first
  end
end
