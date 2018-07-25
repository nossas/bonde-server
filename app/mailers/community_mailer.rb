class CommunityMailer < ApplicationMailer
    def invite_email(invitation, invited_user)
    @invitation = invitation
    @invited_user = invited_user

    headers['X-SMTPAPI'] = {
      filters: {
        subscriptiontrack: {
          settings: {
            enable: 0
          }
        }
      }
    }.to_json

    mail(
      to: invitation.email,
      subject: t('user.email.invitation.subject')
    )
  end
end
