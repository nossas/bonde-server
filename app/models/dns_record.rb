class DnsRecord < ActiveRecord::Base
  belongs_to :dns_hosted_zone
  has_one :community, through: :dns_hosted_zone
  has_many :users, through: :community
    
  validates :dns_hosted_zone_id, :name, :record_type, :value, :ttl, presence: :true

  after_save :update_dns_record_on_aws, unless: :ignore_syncronization?
  after_destroy :delete_dns_record_on_aws, unless: :ignore_syncronization?

  def ignore_syncronization= (val)
    @ignore_syncronization = val
  end

  def ignore_syncronization?
    @ignore_syncronization
  end

  def update_dns_record_on_aws
    DnsService.new.change_resource_record_sets self.dns_hosted_zone.hosted_zone_id, self.name, self.record_type, 
      self.value, self.comment, ttl_seconds: self.ttl
  end

  def delete_dns_record_on_aws
    DnsService.new.change_resource_record_sets self.dns_hosted_zone.hosted_zone_id, self.name, self.record_type, 
      self.value, self.comment, action: 'DELETE'
  end
end
