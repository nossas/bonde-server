require 'pagarme'

class Donation < ActiveRecord::Base
  store_accessor :customer
  belongs_to :widget
  has_one :mobilization, through: :widget
  has_one :organization, through: :mobilization

  after_create :send_mail

  delegate :name, to: :mobilization, prefix: true
  scope :by_widget, -> (widget_id) { where(widget_id: widget_id) if widget_id }

  def self.to_txt
    attributes = %w{id email amount_formatted payment_method mobilization_name
    widget_id created_at customer transaction_id transaction_status}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |donation|
        csv << attributes.map{ |a| donation.send(a) }
      end
    end
  end

  def amount_formatted
    self.amount / 100
  end

  def send_mail
    begin
      DonationsMailer.thank_you_email(self).deliver_later!
    rescue StandardError => e
      logger.error("\n==> ERROR SENDING DONATION EMAIL: #{e.inspect}\n")
    end
  end
end
