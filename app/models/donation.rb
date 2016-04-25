require 'pagarme'

class Donation < ActiveRecord::Base
  belongs_to :widget
  has_one :mobilization, through: :widget
  has_one :organization, through: :mobilization

  after_create :capture_transaction
  after_create :send_mail

  def find_transaction
    @transaction = PagarMe::Transaction.find_by_id(self.token)
  end

  def capture_transaction
    self.transaction do
      @transaction = find_transaction

      begin
        @transaction.capture({
          :amount => self.amount,
          :split_rules => split_rules,
          :metadata => {
            :widget_id => self.widget.sid,
            :mobilization_id => self.mobilization.id,
            :organization_id => self.organization.id
          }
        })
      rescue PagarMeError => e
        logger.error("\n==> ERRO NA DOAÇÃO: #{e.inspect}\n")
      end
    end
  end

  def split_rules
    organization_sr = PagarMe::SplitRule.new(organization_rule).create
    city_sr = PagarMe::SplitRule.new(city_rule).create

    [organization_sr, city_sr]
  end

  def organization_rule
    recipient = Organization.find_by_name("Nossas Cidades").pagarme_recipient_id
    { charge_processing_fee: true, liable: false, percentage: 15, recipient_id: recipient
    }
  end

  def city_rule
    recipient = self.organization.pagarme_recipient_id
    { charge_processing_fee: false, liable: true, percentage: 85, recipient_id: recipient }
  end

  def email
    'someemail@email.com'
  end

  def send_mail
    DonationsMailer.thank_you_email(self).deliver_later
  end

  def client
    PagarMe.api_key = ENV["PAGARME_API_KEY"]
  end
end
