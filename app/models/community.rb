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
          dns_hosted_zones.create!( domain_name: hz )
        else
          data = DnsService.new.get_hosted_zone dhz.id
          dns_hosted_zones.create!( domain_name: hz, response: data.to_json, ignore_syncronization: true )
        end
      end
    end
  end

  def import_aws_records
    dns_hosted_zones.each do |dns_hosted_zone|
      
      if dns_hosted_zone.hosted_zone_id
        list_records = DnsService.new.list_resource_record_sets dns_hosted_zone.hosted_zone_id
        list_records.each do |aws_record|
          aws_record_name = aws_record.name.gsub(/\.$/, '')
          # first, we create a dns_record for each 
          if dns_hosted_zone.dns_records.where("name = ? and record_type = ?", aws_record_name, aws_record.type).count == 0
            dns_hosted_zone.dns_records.create!(name: aws_record_name, record_type: aws_record.type, 
               value: value(aws_record), ttl: aws_record.ttl, ignore_syncronization: true)
          end
        end

        if list_records.select{|lr| lr.name.gsub(/\.$/, '') == dns_hosted_zone.domain_name && lr.type == 'A' }.count  == 0
          dns_hosted_zone.dns_records.create!(name: dns_hosted_zone.domain_name, record_type: 'A', 
             value: ENV['AWS_ROUTE_IP'], ttl: 3600)  
        end

        if list_records.select{|lr| lr.name.gsub(/\.$/, '') == "*.#{dns_hosted_zone.domain_name}" && lr.type == 'A' }.count  == 0
          dns_hosted_zone.dns_records.create!(name: "*.#{dns_hosted_zone.domain_name}", record_type: 'A', 
             value: ENV['AWS_ROUTE_IP'], ttl: 3600)  
        end
      end
    end
  end

  private

  def value aws_record
    aws_record.resource_records.map{|r| r.value}.join("\n")
  end
end
