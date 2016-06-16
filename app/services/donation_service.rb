require 'pagarme'

class DonationService
  def self.run(donation_id)
    donation = Donation.find(donation_id)
    create_transaction(donation)
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

  def new_transaction(donation)
    PagarMe::Transaction.new({
      :card_hash => donation.card_hash,
      :amount => donation.amount,
      :payment_method => donation.payment_method,
      :split_rules => rules,
      :metadata => {
        :widget_id => donation.widget.id,
        :mobilization_id => donation.mobilization.id,
        :organization_id => donation.organization.id,
        :city => donation.organization.city,
        :email => donation.customer.email,
        :donation_id => donation.id
      }
    })
  end

  def create_transaction(donation)
    self.transaction do
      @transaction = new_transaction(donation)
      donation.email = donation.customer.email
      donation.save

      begin
        @transaction.charge

        if donation.payment_method == 'boleto' && Rails.env.production?
          @transaction.collect_payment({email: donation.email})
        end
      rescue PagarMe::PagarMeError => e
        logger.error("\n==> DONATION ERROR: #{e.inspect}\n")
      end
    end
  end

  def rules(donation)
    city = city_rule(donation)

    if organization_rule[:recipient_id] == city[:recipient_id]
      organization_sr = split_rules(organization_rule)
      city_sr = split_rules(city)
      [organization_sr, city_sr]
    else
      city.merge!(percentage: 100)
      [split_rules(city)]
    end
  end

  def split_rules(rule)
    PagarMe::SplitRule.new(rule)
  end

  def city_rule(donation)
    recipient = donation.organization.pagarme_recipient_id
    { charge_processing_fee: true, liable: true, percentage: 85, recipient_id: recipient }
  end

  def organization_rule
    { charge_processing_fee: false, liable: false, percentage: 15, recipient_id: ENV['ORG_RECIPIENT_ID'] }
  end
end
