class DonationsMailer < ApplicationMailer
  def thank_you_email(donation)
    @mobilization = donation.widget.mobilization

    user = @mobilization.user
    sender = user.first_name
    email_address = user.email

    from_address = sender ? "#{sender} <#{email_address}>" : email_address

    mail(
      to: donation.email,
      subject: "[#{@mobilization.name}] Obrigada por doar!",
      from: from_address
    )
  end
end
