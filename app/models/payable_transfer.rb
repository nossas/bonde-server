class PayableTransfer < ActiveRecord::Base
  belongs_to :community
  has_many :donations
end
