require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:activist) { create(:activist) }
  let(:community) { create(:community, email_template_from: 'custom@email.com') }
  let(:notification_template) { create(:notification_template) }
  let(:notification) { create(:notification, community: community, activist: activist, notification_template: notification_template, template_vars: { name: 'lorem2' }) }

  describe "notify" do
    let(:mail) { NotificationMailer.notify(notification) }

    it "should parse and set contents" do
      expect(mail.subject).to eq("hello lorem2")
      expect(mail.to).to eq([activist.email])
      expect(mail.from).to eq([community.email_template_from])
      expect(mail.body.encoded).to include('World lorem2')
      expect(mail['X-SMTPAPI'].present?).to eq(true)
    end
  end
end
