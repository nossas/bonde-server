class CommunityMailer < ApplicationMailer
  def invite_email(invitation)
    @invitation = invitation

    headers['X-SMTPAPI'] = %#{
      "filters": {
        "subscriptiontrack": {
          "settings": {
            "enable": 0
          }
        }
      }
    }#

    mail(
      to: invitation.email,
      subject: t('user.email.invitation.subject')
    )
  end
end
