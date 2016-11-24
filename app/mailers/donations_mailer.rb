class DonationsMailer < ApplicationMailer
  def thank_you_email(donation, force_tests = false)
    if (!Rails.env.test?) or force_tests
      @mobilization = donation.widget.mobilization
      @widget = donation.widget

      ws = @widget.settings
      user = @mobilization.user
      sender = ws['sender_name'] ? ws['sender_name'] : user.first_name
      email_address = ws['sender_email'] ? ws['sender_email'] : user.email
      subject = ws['email_subject'] ? ws['email_subject'] : "[#{@mobilization.name}] Obrigada por doar!"

      from_address = sender ? "#{sender} <#{email_address}>" : email_address

      mail(
        to: donation.customer['email'],
        subject: subject,
        from: from_address
      )
    end
  end
end
