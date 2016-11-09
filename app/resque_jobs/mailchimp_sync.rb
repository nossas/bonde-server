class MailchimpSync
	@queue = :mailchimp_synchro

	def self.perform(form_entry_id, queue) 
		if queue == 'formEntry'
			self.perform_with_formEntry(form_entry_id)
		end
	end

	def self.perform_with_formEntry(form_entry_id)
		formEntry = FormEntry.find(form_entry_id)

		if (not formEntry.widget) or (not formEntry.widget.mailchimp_segment_id)
			formEntry.async_send_to_mailchimp
		else
			if not formEntry.synchronized
				formEntry.send_to_mailchimp
				formEntry.synchronized = true
				formEntry.save
			end
		end
	end
end