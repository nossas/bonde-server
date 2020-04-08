class FormEntryMailer < ApplicationMailer
  def thank_you_email(form_entry, force_tests = false)
    if (!Rails.env.test?) or force_tests

      @widget = form_entry.widget
      @mobilization = @widget.mobilization
      ws = @widget.settings


      if @widget.settings['email_text'].scan(/\$total_inscricoes/).count.positive?
        count = @widget.form_entries.count
        @widget.settings['email_text'] = @widget.settings['email_text'].gsub(/\$total_inscricoes/, count.to_s)
      end

      from_address = get_from_address(ws)
      subject = if ws['email_subject']
                  ws['email_subject']
                else
                  @mobilization.name
                end

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
        to: form_entry.email,
        subject: subject,
        from: from_address
      )
    end
  end

  private

  def get_from_address ws
      if ws['sender_name'] and ws['sender_email']
        "#{ws['sender_name']} <#{ws['sender_email']}>"
      elsif @mobilization.user.first_name
        "#{@mobilization.user.first_name} <#{@mobilization.user.email}>"
      else
        @mobilization.user.email
      end
  end
end
