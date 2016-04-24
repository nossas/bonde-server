require 'pagarme'

class Donation < ActiveRecord::Base
  belongs_to :widget
  has_one :mobilization, through: :widget
  has_one :organization, through: :mobilization

  after_create :send_mail

  def find_transaction
    @transaction = PagarMe::Transaction.find_by_id("468589")
  end

  def email
    'someemail@email.com'
  end

  def send_mail
    DonationsMailer.thank_you_email(self).deliver_later
  end

  def client
    PagarMe.api_key = ENV['PAGARME_API_KEY']
  end
end
