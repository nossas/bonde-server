class Organization < ActiveRecord::Base
  validates :name, :city, presence: true, uniqueness: true
  has_many :payable_transfers
end
