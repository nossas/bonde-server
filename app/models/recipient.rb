class Recipient < ActiveRecord::Base
	validates :pagarme_recipient_id, presence: true
	validates :recipient, presence: true
	validates :community, presence: true

	belongs_to :community

end
