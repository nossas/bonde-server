class DnsRecord < ActiveRecord::Base
  belongs_to :dns_hosted_zone
  has_one :community, through: :dns_hosted_zone
  has_many :users, through: :community

  validates :dns_hosted_zone_id, :name, :record_type, :value, :ttl, presence: :true
end
