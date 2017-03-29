class DnsHostedZone < ActiveRecord::Base
  belongs_to :community

  after_create :create_hosted_zone_on_aws
  before_destroy :delete_hosted_zone

  has_many :dns_records
  has_many :users, through: :community
  
  validates :community_id, presence: true
  validates :domain_name, presence: true, length: {maximum: 255}

  def delegation_set_servers
    self.response['delegation_set']['name_servers']
  end

  def hosted_zone_id
    self.response['hosted_zone']['id']
  end

  def create_hosted_zone_on_aws
    (self.update_attributes response: (DnsService.new.create_hosted_zone domain_name, comment: comment).to_json) unless response
  end

  def delete_hosted_zone
    (DnsService.new.delete_hosted_zone hosted_zone_id) if hosted_zone_id
  end

end
