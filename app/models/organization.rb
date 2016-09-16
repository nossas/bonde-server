class Organization < ActiveRecord::Base
  validates :name, :city, presence: true, uniqueness: true
  has_many :payable_transfers
  has_many :payable_details
  has_many :mobilizations
  has_many :users, through: :mobilizations
end
