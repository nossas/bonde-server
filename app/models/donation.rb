class Donation < ActiveRecord::Base
  store_accessor :customer
  belongs_to :widget
  belongs_to :activist
  has_one :mobilization, through: :widget
  has_one :organization, through: :mobilization
  belongs_to :parent, class_name: 'Donation'
  belongs_to :payable_transfer
  has_many :payments
  has_many :payable_details

  after_create :send_mail, unless: :skip?

  delegate :name, to: :mobilization, prefix: true

  default_scope { joins(:mobilization) }
  scope :by_widget, -> (widget_id) { where(widget_id: widget_id) if widget_id }
  scope :by_organization, -> (organization_id) { where("organization_id = ?", organization_id) if organization_id }

  def boleto?
    self.payment_method == 'boleto'
  end

  def self.to_txt
    attributes = %w{
    id email amount_formatted payment_method mobilization_name widget_id
    created_at donor transaction_id transaction_status subscription_id
    }

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |donation|
        csv << attributes.map{ |a| donation.send(a) }
      end
    end
  end

  def donor
    self.activist.name if self.activist
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
