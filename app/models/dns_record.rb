class DnsRecord < ActiveRecord::Base
  belongs_to :dns_hosted_zone
  has_one :community, through: :dns_hosted_zone
  has_many :users, through: :community
    
  validates :dns_hosted_zone_id, :name, :record_type, :value, :ttl, presence: :true

  after_save :update_dns_record_on_aws, unless: :ignore_syncronization?
  after_destroy :delete_dns_record_on_aws, unless: :ignore_syncronization?

  scope :only_unsensible, -> { 
      joins(:dns_hosted_zone).
      where( %Q[
          ( not ( 
            dns_hosted_zones.domain_name = dns_records.name and 
            (dns_records.record_type = 'SOA' or dns_records.record_type = 'NS' or dns_records.record_type = 'A' or dns_records.record_type = 'AAAA') 
          ) ) and
          ( not ( 
            name = '*.' || dns_hosted_zones.domain_name  and
            (dns_records.record_type = 'CNAME' or dns_records.record_type = 'A' or dns_records.record_type = 'AAAA') 
          ) )
      ] )
    }

  def ignore_syncronization= (val)
    @ignore_syncronization = val
  end

  def ignore_syncronization?
    @ignore_syncronization
  end

  def update_dns_record_on_aws
    DnsService.new.change_resource_record_sets self.dns_hosted_zone.hosted_zone_id, self.name, self.record_type, 
      values: self.value.split("\n"), comments: self.comment, ttl_seconds: self.ttl
  end

  def delete_dns_record_on_aws
    begin
      DnsService.new.change_resource_record_sets self.dns_hosted_zone.hosted_zone_id, self.name, self.record_type, 
        values: self.value.split("\n"), ttl_seconds: self.ttl, action: 'DELETE' unless record_automatic?
    rescue Aws::Route53::Errors::InvalidChangeBatch => ex
      if (ex.message =~ /^Tried to delete resource record set .+ but it was not found$/).nil?
        throw ex
      end
    end
  end

  def self.create_from_record aws_record, hosted_zone_id, ignore_syncronization: false
    dns_record = DnsRecord.new
    dns_record.dns_hosted_zone_id = hosted_zone_id
    dns_record.name = aws_record.name.gsub(/\.$/, '')
    dns_record.record_type = aws_record.type
    dns_record.value = aws_record.resource_records.map{|r| r.value}.join("\n")
    dns_record.ttl = aws_record.ttl
    dns_record.ignore_syncronization = ignore_syncronization
    dns_record.save!
  end

  private

  def record_automatic?
    self.name == dns_hosted_zone.domain_name &&
    self.record_type =~ /NS|SOA/
  end
end
