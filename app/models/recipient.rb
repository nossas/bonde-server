class Recipient < ActiveRecord::Base
	validates :pagarme_recipient_id, presence: true
	validates :recipient, presence: true
	validates :community, presence: true

	belongs_to :community
  has_many :balance_operations

  def update_from_pagarme
    raise PagarMe::PagarMeError.new "pagarme_recipient_id is empty" unless self.pagarme_recipient_id 

    recipient_info = PagarMe::Recipient.find_by_id self.pagarme_recipient_id
    self.transfer_day = recipient_info.transfer_day
    self.transfer_enabled = recipient_info.transfer_enabled
    self.recipient = recipient_info.as_json
    self.save!
  end

  def gateway_recipient
    @gateway_recipient ||= PagarMe::Recipient.find pagarme_recipient_id
  end
end
