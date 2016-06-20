require 'pagarme'

class DonationService
  def self.run(donation, address)
    self.create_transaction(donation, address)
  end

  # Helper method to find a transaction by metadata
  # github.com/catarse/catarse_pagarme
  def self.find_by_metadata(key, value)
    request = PagarMe::Request.new('/search', 'GET')
    query = {
      type: 'transaction',
      query: {
        from: 0,
        size: 1,
        query: {
          bool: {
            must: {
              match: {
                "metadata.#{key}" => value
              }
            }
          }
        }
      }.to_json
    }

    request.parameters.merge!(query)
    response = request.run
    response.try(:[], "hits").try(:[], "hits").try(:[], 0).try(:[], "_source")
  end

  private

  def self.new_transaction(donation)
    self.find_or_create_card(donation) unless donation.boleto?

    PagarMe::Transaction.new({
      card_id: donation.credit_card,
      amount: donation.amount,
      payment_method: donation.payment_method,
      split_rules: self.rules(donation),
      metadata: {
        widget_id: donation.widget.id,
        mobilization_id: donation.mobilization.id,
        organization_id: donation.organization.id,
        city: donation.organization.city,
        email: donation.activist.email,
        donation_id: donation.id
      }
    })
  end

  def self.create_transaction(donation, address)
    ActiveRecord::Base.transaction do
      @transaction = self.new_transaction(donation)
      @transaction.customer = self.customer_params(donation, address)
      donation.email = donation.activist.email
      donation.save

      begin
        @transaction.charge
        donation.update_attributes(
          transaction_id: @transaction.id,
          transaction_status: @transaction.status
        )

        if donation.boleto? && Rails.env.production?
          @transaction.collect_payment({email: donation.email})
        end
      rescue PagarMe::PagarMeError => e
        Rails.logger.error("\n==> DONATION ERROR: #{e.inspect}\n")
      end
    end
  end

  def self.find_or_create_card(donation)
    return PagarMe::Card.find(donation.credit_card) if donation.credit_card
    card = PagarMe::Card.new(card_hash: donation.card_hash)

    if card.create
      CreditCard.create(
        last_digits: card.last_digits,
        card_brand: card.brand,
        card_id: card.id,
        expiration_date: card.expiration_date,
        activist: donation.activist
      )
      donation.update_attributes(credit_card: card.id)
    end
  end

  def self.rules(donation)
    city = self.city_rule(donation)

    if self.organization_rule[:recipient_id] != city[:recipient_id]
      organization_sr = self.split_rules(self.organization_rule)
      city_sr = self.split_rules(city)
      [organization_sr, city_sr]
    else
      city.merge!(percentage: 100)
      [self.split_rules(city)]
    end
  end

  def self.split_rules(rule)
    PagarMe::SplitRule.new(rule)
  end

  def self.city_rule(donation)
    recipient = donation.organization.pagarme_recipient_id
    { charge_processing_fee: true, liable: true, percentage: 85, recipient_id: recipient }
  end

  def self.organization_rule
    { charge_processing_fee: false, liable: false, percentage: 15, recipient_id: ENV['ORG_RECIPIENT_ID'] }
  end

  def self.customer_params(donation, address)
    {
      name: donation.activist.name,
      email: donation.activist.email,
      document_number: donation.activist.document_number,
      phone: {
        ddd: self.phone(donation.activist.phone)[:ddd],
        number: self.phone(donation.activist.phone)[:number]
      },
      address: {
        street: address.street,
        street_number: address.street_number,
        complementary: address.complementary,
        zipcode: address.zipcode,
        neighborhood: address.neighborhood
      }
    }
  end

  def self.phone(number)
    phone_number = number.gsub(/\D/, ' ').split(' ')
    { ddd: phone_number[0], number: phone_number[1] }
  end
end
