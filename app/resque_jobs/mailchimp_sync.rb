class MailchimpSync
	@queue = :mailchimp_synchro

	def self.perform(form_entry_id)
		formEntry = FormEntry.find(form_entry_id)

		if not formEntry.synchronized
			formEntry.send_to_mailchimp
			formEntry.synchronized = true
			formEntry.save
		end
	end
end