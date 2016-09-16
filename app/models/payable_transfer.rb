class PayableTransfer < ActiveRecord::Base
  belongs_to :organization
  has_many :donations
end
