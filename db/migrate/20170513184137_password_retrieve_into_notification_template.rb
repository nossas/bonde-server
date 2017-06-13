class PasswordRetrieveIntoNotificationTemplate < ActiveRecord::Migration
  def up
    NotificationTemplate.create! label: :bonde_password_retrieve, subject_template: 'Sobre seu acesso no bonde',
        body_template: 'Olá, {{user.name}}.  <br> Foi solicitadoa a geração de uma nova senha para sua conta no bonde, e a nova senha é {{new_password}}.'
  end

  def down
    notification_template = NotificationTemplate.find_by_label :bonde_password_retrieve
    notification_template.destroy if notification_template
  end
end
