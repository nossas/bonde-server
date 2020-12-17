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
  validates :domain_name, presence: true, length: {maximum: 254}
  validates_uniqueness_of :domain_name

  validates :domain_name, format: { with: /\A([a-z0-9\-]{0,63}\.)*([a-z0-9\-]{0,63})\z/ , 
      message: I18n.t('activerecord.errors.models.dns_hosted_zone.attributes.domain_name.segments') }

  def ignore_syncronization= (val)
    @ignore_syncronization = val
  end

  def ignore_syncronization?
    @ignore_syncronization
  end

  def delegation_set_servers
    if self.response and self.response['delegation_set']
      self.response['delegation_set']['name_servers']
    elsif self.response
      self.response['DelegationSet']['NameServers']
    end
  end

  def self.execute_sql(*sql_array)
   connection.execute(send(:sanitize_sql_array, sql_array))
  end

  def hosted_zone_id
    if self.response and self.response['hosted_zone']
      self.response['hosted_zone']['id']
    elsif self.response
      self.response['HostedZone']['Id']
    end
  end

  def create_hosted_zone_on_aws
    rs = DnsService.new.list_hosted_zones
    record_filtered = rs.select{|record| record.name.gsub(/\.$/, '') == self.domain_name}
    if (record_filtered.count == 0)
      (self.update_attributes response: (DnsService.new.create_hosted_zone domain_name, comment: comment).to_json)
    else
      (self.update_attributes response: (DnsService.new.get_hosted_zone(record_filtered.first.id)).to_json)
    end
  end

  def delete_hosted_zone
    self.dns_records.each {|d|d.delete}
    self.reload

    if hosted_zone_id and (! ignore_syncronization?)
      begin 
        dns_service = DnsService.new

        records = dns_service.list_resource_record_sets hosted_zone_id
        records.each do |rec|
          begin
            dns_service.change_resource_record_sets hosted_zone_id, rec.name, rec.type, 
              values: rec.resource_records.map{|o| o['value']}, ttl_seconds: rec.ttl , action: 'DELETE' unless rec.type =~ /SOA|NS/ && rec.name == "#{domain_name}."
          rescue StandardError => e
            p e
          end
        end

        dns_service.delete_hosted_zone hosted_zone_id, domain_name
      rescue StandardError => ex
        if (ex.message =~ /^No hosted zone found with ID/).nil?
          throw ex
        end
      end
    end
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
    dns_service.change_resource_record_sets self.hosted_zone_id, self.domain_name, 'A', values: [ENV['AWS_ROUTE_IP']], comments: 'autocreated'
    dns_service.change_resource_record_sets self.hosted_zone_id, "*.#{self.domain_name}", 'A', values: [ENV['AWS_ROUTE_IP']], comments: 'autocreated'
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
    begin
      if self.delegation_set_servers
        resp = Resolver(self.domain_name, Net::DNS::NS).answer
        comparation = resp.map{|q| q.value.gsub(/\.$/,'')}.sort == (self.delegation_set_servers||[]).sort
      end
    rescue Net::DNS::Resolver::NoResponseError
    end
    comparation
  end
end
