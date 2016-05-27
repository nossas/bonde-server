require 'pagarme'

class Donation < ActiveRecord::Base
  store_accessor :customer
  belongs_to :widget
  has_one :mobilization, through: :widget
  has_one :organization, through: :mobilization

  after_create :create_transaction, unless: :skip?
  after_create :send_mail

  scope :by_widget, -> (widget_id) { where(widget_id: widget_id) }

  def new_transaction
    PagarMe::Transaction.new({
      :card_hash => self.card_hash,
      :amount => self.amount,
      :payment_method => self.payment_method,
      :split_rules => split_rules,
      :metadata => {
        :widget_id => self.widget.id,
        :mobilization_id => self.mobilization.id,
        :organization_id => self.organization.id,
        :city => self.organization.city,
        :email => self.customer["email"] }
    })
  end

  def create_transaction
    self.transaction do
      @transaction = new_transaction
      self.email = self.customer["email"]
      self.save

      begin
        @transaction.charge

        if self.payment_method == 'boleto' && Rails.env.production?
          @transaction.collect_payment({email: self.email})
        end
      rescue PagarMe::PagarMeError => e
        logger.error("\n==> DONATION ERROR: #{e.inspect}\n")
      end
    end
  end

  def split_rules
    unless organization_rule[:recipient_id] == city_rule[:recipient_id]
      organization_sr = PagarMe::SplitRule.new(organization_rule)
      city_sr = PagarMe::SplitRule.new(city_rule)

      [organization_sr, city_sr]
    end
  end

  def organization_rule
    { charge_processing_fee: false, liable: false, percentage: 15, recipient_id: ENV['ORG_RECIPIENT_ID'] }
  end

  def city_rule
    recipient = self.organization.pagarme_recipient_id
    { charge_processing_fee: true, liable: true, percentage: 85, recipient_id: recipient }
  end

  def send_mail
    begin
      DonationsMailer.thank_you_email(self).deliver_later!
    rescue StandardError => e
      logger.error("\n==> ERROR SENDING DONATION EMAIL: #{e.inspect}\n")
    end
  end

  def client
    PagarMe.api_key = ENV["PAGARME_API_KEY"]
  end
end
