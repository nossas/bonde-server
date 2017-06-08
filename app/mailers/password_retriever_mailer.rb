class PasswordRetrieverMailer < ApplicationMailer
  def retrieve user
    @user = user
    mail to: user.email, subject: t('mailer.password.retrieve.subject')
  end
end