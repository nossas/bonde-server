class FormEntryMailer < ApplicationMailer
  def thank_you_email(form_entry)
    @widget = form_entry.widget
    @mobilization = @widget.mobilization

    from_address = if @mobilization.user.first_name
                     "#{@mobilization.user.first_name} <#{@mobilization.user.email}>"
                   else
                     @mobilization.user.email
                   end

    mail(
      to: form_entry.email,
      subject: @mobilization.name,
      from: from_address
    )
  end
end
