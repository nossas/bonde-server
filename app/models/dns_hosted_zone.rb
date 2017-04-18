require 'net/dns'

class DnsHostedZone < ActiveRecord::Base
  belongs_to :community

  after_create :create_hosted_zone_on_aws, unless: :ignore_syncronization?
  after_create :create_default_records_on_aws, unless: :ignore_syncronization?
  after_create :load_record_from_aws, unless: :ignore_syncronization?

  before_destroy :delete_hosted_zone

  has_many :dns_records
  has_many :users, through: :community
  
  validates :community_id, presence: true
  validates :domain_name, presence: true, length: {maximum: 255}

  def ignore_syncronization= (val)
    @ignore_syncronization = val
  end

  def ignore_syncronization?
    @ignore_syncronization
  end

  def delegation_set_servers
    self.response['delegation_set']['name_servers'] if self.response
  end

  def hosted_zone_id
    self.response['hosted_zone']['id'] if self.response
  end

  def create_hosted_zone_on_aws
    rs = DnsService.new.list_hosted_zones
    record_filtered = rs.select{|record| record.name.gsub(/\.$/, '') == self.domain_name}
    if (record_filtered.count == 0)
      (self.update_attributes response: (DnsService.new.create_hosted_zone domain_name, comment: comment).to_json)
    else
      p record_filtered.first
      (self.update_attributes response: (DnsService.new.get_hosted_zone(record_filtered.first.id)).to_json)
    end
  end

  def delete_hosted_zone
    (DnsService.new.delete_hosted_zone hosted_zone_id) if hosted_zone_id and (! ignore_syncronization?)
  end

  def load_record_from_aws
    if self.hosted_zone_id
      rs = DnsService.new.list_resource_record_sets self.hosted_zone_id
      rs.each do |record_set| 
        DnsRecord.create_from_record(record_set, self.id, ignore_syncronization: true) if 
          dns_records.where("(name = ? and record_type = ?)", (record_set.name.gsub(/\.$/, '')), record_set.type).
          count == 0
      end
    end
  end

  def create_default_records_on_aws
    dns_service = DnsService.new
    dns_service.change_resource_record_sets self.hosted_zone_id, self.domain_name, 'A', [ENV['AWS_ROUTE_IP']], 'autocreated'
    dns_service.change_resource_record_sets self.hosted_zone_id, "*.#{self.domain_name}", 'A', [ENV['AWS_ROUTE_IP']], 'autocreated'
  end

  def create_google_mail_entries url: nil, ttl:3600
    dns_records.create! name: (url || self.domain_name), record_type: 'MX', value: google_mx_values.join("\n"), comment: 'autocreated', ttl: ttl
  end

  def check_ns_correctly_filled!
    unless self.ns_ok
      self.ns_ok = compare_ns
      self.save! if self.ns_ok
    end
    self.ns_ok
  end

  private

  def google_mx_values
    [ '1 aspmx.l.google.com',
      '5 alt1.aspmx.l.google.com',
      '5 alt2.aspmx.l.google.com',
      '10 alt3.aspmx.l.google.com',
      '10 alt4.aspmx.l.google.com' ]
  end

  def compare_ns
    comparation = false
    if self.delegation_set_servers
      resp = Resolver(self.domain_name, Net::DNS::NS).answer
      comparation = resp.map{|q| q.value.gsub(/\.$/,'')}.sort == (self.delegation_set_servers||[]).sort
    end
    comparation
  end
end
