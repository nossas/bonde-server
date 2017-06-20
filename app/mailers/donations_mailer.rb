class DonationsMailer < ApplicationMailer
  def thank_you_email(donation, force_tests = false)
    if (!Rails.env.test?) or force_tests
      @mobilization = donation.widget.mobilization
      @widget = donation.widget

      ws = @widget.settings
      user = @mobilization.user
      sender = get_sender ws, user
      email_address = ws['sender_email'] ? ws['sender_email'] : user.email
      subject = ws['email_subject'] ? ws['email_subject'] : "[#{@mobilization.name}] Obrigada por doar!"

      from_address = sender ? "#{sender} <#{email_address}>" : email_address

      headers['X-SMTPAPI'] = %#{
        "filters": {
          "subscriptiontrack": {
            "settings": {
              "enable": 0
            }
          },
          "bypass_list_management" : {
            "settings" : {
              "enable" : 1
            }
          }
        }
      }#

      mail(
        to: donation.activist.try(:email) || donation.customer['email'],
        subject: subject,
        from: from_address
      )
    end
  end

  def get_sender ws, user
    ws['sender_name'] ? ws['sender_name'] : user.first_name
  end
end
