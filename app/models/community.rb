class Community < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  
  has_many :payable_transfers
  has_many :payable_details
  has_many :donation_reports
  has_many :mobilizations
  has_many :community_users
  has_many :users, through: :community_users
  has_many :agg_activists
  has_many :recipients
  has_many :activist_actions
  has_many :dns_hosted_zones

  belongs_to :recipient

  def pagarme_recipient_id
    recipient.try(:pagarme_recipient_id)
  end

  def transfer_day
    recipient.try(:transfer_day)
  end

  def transfer_enabled
    recipient.try(:transfer_enabled)
  end

  def total_to_receive_from_subscriptions
    @total_to_receive_from_subscriptions ||= subscription_payables_to_transfer.sum(:value_without_fee)
  end

  def subscription_payables_to_transfer
    @subscription_payables_to_transfer ||= payable_details.is_paid.from_subscription.over_limit_to_transfer
  end

  def synchronize_hosted_zones 
    aws_hosted_zones = DnsService.new.list_hosted_zones
    
    zones = self.mobilizations.
      map{|m| m.custom_domain}.
      flatten.
      uniq.
      map{|d| (d||"").scan(/([a-z]+\.[a-z]{,3}(\.[a-z]{2})?)$/i)[0]}.
      uniq.
      select{|a| a}.map{|x|x[0]}.uniq

    zones.each do |hz|
      if dns_hosted_zones.where("domain_name = ?", hz).count == 0
        dhz = (aws_hosted_zones.select {|hosted_zone| hosted_zone.name.gsub(/\.$/, '') == hz}[0])
        unless dhz # The is no HostedZone created on amazon
          dns_hosted_zones.create!( domain_name: hz)
        else
          data = DnsService.new.get_hosted_zone dhz.id
          dns_hosted_zones.create!( domain_name: hz, response: data.to_json)
        end
      end
    end
  end
end
