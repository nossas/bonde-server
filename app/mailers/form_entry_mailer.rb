class FormEntryMailer < ApplicationMailer
  def thank_you_email(form_entry, force_tests = false)
    if (!Rails.env.test?) or force_tests

      @widget = form_entry.widget
      @mobilization = @widget.mobilization
      ws = @widget.settings

      from_address = get_from_address(ws)
      subject = if ws['email_subject']
                  ws['email_subject']
                else
                  @mobilization.name
                end

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
