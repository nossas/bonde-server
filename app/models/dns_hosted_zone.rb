class DnsHostedZone < ActiveRecord::Base
  belongs_to :community
  has_many :users, through: :community

  validates :community_id, presence: true
  validates :domain_name, presence: true, length: {maximum: 255}
end
