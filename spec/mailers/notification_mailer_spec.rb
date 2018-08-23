require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:activist) { create(:activist) }

  let(:user) { create(:user) }

  let(:community) { create(:community, email_template_from: 'custom@email.com') }
  let(:notification_template) { create(:notification_template) }

  let(:notification) { create(:notification, community: community, activist: activist, notification_template: notification_template, template_vars: { name: 'lorem2' }) }
  let(:notification2) { create(:notification, user: user, notification_template: notification_template, template_vars: { name: 'lorem2' }) }
  let(:notification3) { create(:notification, email: 'ask@me.com', notification_template: notification_template, template_vars: { name: 'lorem2' }) }

  describe "#notify" do
    context "Addressed to an activist" do
      let(:mail) { NotificationMailer.notify(notification) }

      it "should parse and set contents" do
        expect(mail.subject).to eq("hello lorem2")
        expect(mail.to).to eq([activist.email])
        expect(mail.from).to eq([community.email_template_from])
        expect(mail.body.encoded).to include('World lorem2')
        expect(mail['X-SMTPAPI'].present?).to eq(true)
      end
    end

    context "Addressed to an user" do
      let(:mail) { NotificationMailer.notify(notification2) }

      it "should parse and set contents" do
        expect(mail.subject).to eq("hello lorem2")
        expect(mail.to).to eq([user.email])
        expect(mail.body.encoded).to include('World lorem2')
        expect(mail['X-SMTPAPI'].present?).to eq(true)
      end
    end

    context "Addressed to an email" do
      let(:mail) { NotificationMailer.notify(notification3) }

      it "should parse and set contents" do
        expect(mail.subject).to eq("hello lorem2")
        expect(mail.to).to eq(['ask@me.com'])
        expect(mail.body.encoded).to include('World lorem2')
        expect(mail['X-SMTPAPI'].present?).to eq(true)
      end
    end
  end

  describe "#auto_fire" do
    let(:activist) { create(:activist, email: "activist@gmail.com") }
    let(:user) { create(:user) }
    let(:community) { create(:community, email_template_from: 'custom@email.com') }
    let(:template_donation) { create(:notification_template, label: 'thank_you_donation', subject_template: '{{subject}}', body_template: "{{body}}") }
    let(:template_form_entry) { create(:notification_template, label: 'thank_you_form_entry', subject_template: '{{subject}}', body_template: "{{body}}") }
    let(:notification_thank_you_donation) { create(:notification, community: community, activist: activist, notification_template: template_donation, template_vars: { name: 'lorem2', subject: 'Thank you for your donation', body: 'Thanks for your donation for the Mobi 01' }, notification_type: 'auto_fire') }
    let(:notification_form_entry) { create(:notification, community: community, email: 'jonhdoe@example.org', notification_template: template_form_entry, template_vars: { name: 'John Doe', subject: 'Thank you for supporting Mobi 01', body: 'Hello welcome' }, notification_type: 'auto_fire') }

    context 'send auto_fire of donation' do
      let(:mail) { NotificationMailer.notify(notification_thank_you_donation) }

      it 'should be a auto_fire' do
        expect(mail.subject).to eq("Thank you for your donation")
        expect(mail.to).to eq(["activist@gmail.com"])
        expect(mail.body.encoded).to include("Thanks for your donation for the Mobi 01")
        expect(mail['X-SMTPAPI'].present?).to eq(true)
      end
    end

    context 'send auto_fire of form_entry' do
      let(:mail) { NotificationMailer.notify(notification_form_entry) }

      it 'should be a auto_fire' do
        expect(mail.subject).to eq("Thank you for supporting Mobi 01")
        expect(mail.to).to eq(["jonhdoe@example.org"])
        expect(mail.body.encoded).to include("Hello welcome")
        expect(mail['X-SMTPAPI'].present?).to eq(true)
      end
    end
  end
end
