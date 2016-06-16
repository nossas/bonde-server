require 'pagarme'

class DonationService
  def self.run(donation_id)
    donation = Donation.find(donation_id)
    self.create_transaction(donation)
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
    PagarMe::Transaction.new({
      :card_hash => donation.card_hash,
      :amount => donation.amount,
      :payment_method => donation.payment_method,
      :split_rules => self.rules(donation),
      :metadata => {
        :widget_id => donation.widget.id,
        :mobilization_id => donation.mobilization.id,
        :organization_id => donation.organization.id,
        :city => donation.organization.city,
        :email => donation.activist.email,
        :donation_id => donation.id
      }
    })
  end

  def self.create_transaction(donation)
    ActiveRecord::Base.transaction do
      @transaction = self.new_transaction(donation)
      donation.email = donation.activist.email
      donation.save

      begin
        @transaction.charge

        if donation.payment_method == 'boleto' && Rails.env.production?
          @transaction.collect_payment({email: donation.email})
        end
      rescue PagarMe::PagarMeError => e
        Rails.logger.error("\n==> DONATION ERROR: #{e.inspect}\n")
      end
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
end
