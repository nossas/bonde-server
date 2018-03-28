class CommunityMailer < ApplicationMailer
    def invite_email(invitation, has_user)
    @invitation = invitation
    @has_user = has_user

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
