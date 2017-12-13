class Community < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true

  has_many :payable_transfers
  has_many :payable_details
  has_many :donation_reports
  has_many :mobilizations
  has_many :blocks, through: :mobilizations
  has_many :widgets, through: :blocks
  has_many :community_users
  has_many :users, through: :community_users
  has_many :agg_activists
  has_many :recipients
  has_many :activist_actions
  has_many :dns_hosted_zones

  has_many :notification_templates
  has_many :notifications

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

  def import_hosted_zones
    aws_hosted_zones = DnsService.new.list_hosted_zones

    zones = self.mobilizations.
      map{|m| m.custom_domain}.
      flatten.
      uniq.
      map{|d| (d||"").scan(/([a-z]+\.[a-z]{,3}(\.[a-z]{2})?)$/i)[0]}.
      uniq.
      select{|a| a}.map{|x|x[0]}.uniq


    problematic_zones = []
    zones.each do |hz|
      filtered_zones = dns_hosted_zones.where("domain_name = ?", hz)
      dhz = (aws_hosted_zones.select {|hosted_zone| hosted_zone.name.gsub(/\.$/, '') == hz}[0])
      begin
        unless dhz # The is no HostedZone created on amazon
          if filtered_zones.count == 0
            dns_hosted_zones.create!( domain_name: hz, ignore_syncronization: true )
          else
            filtered_zones[0].response = nil
          end
        else
          data = DnsService.new.get_hosted_zone dhz.id
          if filtered_zones.count == 0
            dns_hosted_zones.create!( domain_name: hz, response: data.to_json, ignore_syncronization: true )
          else
            filtered_zones[0].response = data.to_json
          end
        end
      rescue
        problematic_zones << hz
      end
    end
    problematic_zones
  end

  def export_hosted_zones
    dns_hosted_zones.each do |dns_hosted_zone|
      dns_hosted_zone.create_hosted_zone_on_aws unless dns_hosted_zone.hosted_zone_id
    end
  end

  def import_aws_records
    dns_hosted_zones.each do |dns_hosted_zone|

      if dns_hosted_zone.hosted_zone_id
        list_records = DnsService.new.list_resource_record_sets dns_hosted_zone.hosted_zone_id
        list_records.each do |aws_record|
          aws_record_name = eval(%Q("#{aws_record.name.gsub(/\.$/, '')}"))
          # first, we create a dns_record for each
          if dns_hosted_zone.dns_records.where("name = ? and record_type = ?", aws_record_name, aws_record.type).count == 0
            dns_hosted_zone.dns_records.create!(name: aws_record_name, record_type: aws_record.type,
               value: value(aws_record), ttl: aws_record.ttl, ignore_syncronization: true) unless value(aws_record).empty?
          end
        end
      end
    end
  end

  def export_aws_records
    dns_hosted_zones.map{|r| r.dns_records}.flatten.each do |dns_record|
      dns_record.update_dns_record_on_aws
    end
  end

  def invite_member email, inviter, role
    invitation = Invitation.create email: email, community: self, user: inviter, expires: (DateTime.now + 3.days), role: role

    if invitation.valid?
      invitation.invitation_email
    elsif invitation.code.present? && Invitation.where(code: invitation.code).exists?
      invitation = Invitation.find_by code: invitation.code
      invitation.invitation_email if invitation.present?
    end

    invitation
  end

  def resync_all
    if !mailchimp_sync_request_at.present? || (mailchimp_sync_request_at + 10.minutes < DateTime.now)
      update_column(:mailchimp_sync_request_at, DateTime.now)
      CommunityMailchimpResyncWorker.perform_async(self.id)
    end
  end

  private

  def value aws_record
    aws_record.resource_records.map{|r| r.value}.join("\n")
  end

end
