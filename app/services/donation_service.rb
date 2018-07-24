require 'pagarme'

class DonationService
  def self.update_from_gateway(donation)
    transaction = PagarMe::Transaction.find_by_id donation.transaction_id
    donation.update_attributes(
      transaction_status: transaction.status,
      payables: transaction.payables.to_json,
      gateway_data: transaction.to_json
    )
  end

  def self.run(donation, address)
    self.create_transaction(donation, address)
  end

  def self.new_transaction(donation)
    pagarme_data = {
      card_id: donation.credit_card,
      amount: donation.amount,
      payment_method: donation.payment_method,
      split_rules: self.rules(donation),
      postback_url: Rails.application.routes.url_helpers.create_postback_url(protocol: 'https'),
      metadata: {
        widget_id: donation.widget.id,
        mobilization_id: donation.mobilization.id,
        community_id: donation.community.id,
        city: donation.community.city,
        email: donation.activist.email,
        donation_id: donation.id
      }
    }

    pagarme_data[:card_hash] = donation.card_hash if donation.process_card_hash?

    PagarMe::Transaction.new(pagarme_data)
  end

  def self.create_transaction(donation, address)
    ActiveRecord::Base.transaction do
      @transaction = self.new_transaction(donation)
      @transaction.customer = self.customer_params(donation, address)
      donation.email = donation.activist.email
      donation.save

      begin
        @transaction.charge

        self.find_or_create_card(donation) unless donation.boleto?

        if donation.boleto? && Rails.env.production?
          @transaction.collect_payment({email: donation.email})
        end

        donation.update_attributes(
          transaction_id: @transaction.id,
          gateway_data: @transaction.try(:to_json),
          payables: @transaction.try(:payables)
        )

        donation.transition_to(
          @transaction.status.to_sym, @transaction.try(:to_json))
        process_subscription(donation)

        status_transaction = PagarMe::Transaction.find_by_id(@transaction.id).status

        return status_transaction

      rescue PagarMe::PagarMeError => e
        Raven.capture_exception(e) unless Rails.env.test?
        Rails.logger.error("\n==> DONATION ERROR: #{e.inspect}\n")
        e
      end
    end
  end

  def self.process_subscription(donation)
    if donation.subscription? && !donation.subscription_relation.present?
      subscription = Subscription.create!(
        widget_id: donation.widget_id,
        activist_id: donation.activist_id,
        community_id: donation.community.id,
        status: 'pending',
        amount: donation.amount,
        card_data: @transaction.card.try(:to_json),
        gateway_customer_id: @transaction.customer.try(:id),
        payment_method: donation.payment_method)
      donation.update_attribute(:local_subscription_id, subscription.id)

      subscription.reload
      subscription.process_status_changes(@transaction.status, @transaction.try(:to_h))
    end
  end

  def self.load_transaction transaction_id
    PagarMe::Transaction.find_by_id transaction_id
  end

  def self.find_or_create_card(donation)
    return PagarMe::Card.find(donation.credit_card) if donation.credit_card
    card = PagarMe::Card.find(@transaction.try(:card).try(:id))

    if card.present?
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

    if self.community_rule[:recipient_id] != city[:recipient_id]
      community_sr = self.split_rules(self.community_rule)
      city_sr = self.split_rules(city)
      [community_sr, city_sr]
    else
      city.merge!(percentage: 100)
      [self.split_rules(city)]
    end
  end

  def self.split_rules(rule)
    PagarMe::SplitRule.new(rule)
  end

  def self.city_rule(donation)
    recipient = donation.community.pagarme_recipient_id
    { charge_processing_fee: false, liable: true, percentage: 87, recipient_id: recipient }
  end

  def self.community_rule
    { charge_processing_fee: true, liable: false, percentage: 13, recipient_id: ENV['ORG_RECIPIENT_ID'] }
  end

  def self.customer_params(donation, address)
    return_customer_params = {
      name: donation.activist.name || donation.checkout_data['name'],
      email: donation.activist.email || donation.checkout_data['email'],
      document_number: donation.activist.document_number || donation.checkout_data['document_number'],
      address: {
        street: address.street,
        street_number: address.street_number,
        complementary: address.complementary,
        zipcode: address.zipcode,
        neighborhood: address.neighborhood
      }
    }
    return_customer_params[:phone] = {
      ddd: self.phone(donation.activist.phone)[:ddd],
      number: self.phone(donation.activist.phone)[:number]
    } if self.phone(donation.activist.phone)
    return_customer_params
  end

  def self.phone(number)
    if number
      phone_number = number.gsub(/\D/, ' ').split(' ')
      { ddd: phone_number[0], number: phone_number[1] }
    else
      nil
    end
  end
end
