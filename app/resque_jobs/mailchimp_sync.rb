class MailchimpSync
	@queue = :mailchimp_synchro

	def self.perform(id, queue) 
		if queue == 'formEntry'
			self.perform_with_formEntry(id)
		elsif queue == 'widget'
			self.perform_with_widget(id)
		elsif queue == 'activist_pressure'
			self.perform_with_activist_pressure(id)
		elsif queue == 'activist_match'
			self.perform_with_activist_match(id)
		end

	end

	def self.perform_with_formEntry(form_entry_id)
		formEntry = FormEntry.find(form_entry_id)

		if (formEntry.widget)
			if (not formEntry.widget.mailchimp_segment_id)
				formEntry.widget.async_create_mailchimp_segment
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

	def self.perform_with_widget(widget_id)
		widget = Widget.find(widget_id)

		widget.create_mailchimp_segment
	end

	def self.perform_with_activist_pressure(activist_pressure_id)
		activistPressure = ActivistPressure.find(activist_pressure_id)
		if ( not activistPressure.widget)  or (not activistPressure.widget.id)
			activistPressure.async_update_mailchimp
		else
			activistPressure.update_mailchimp
		end
	end

	def self.perform_with_activist_match(activist_pressure_id)
		activistMatch = ActivistMatch.find(activist_pressure_id)
		if ( not activistMatch.activist) or (not activistMatch.activist.id) or ( not activistMatch.match) or (not activistMatch.match.id)
			activistMatch.async_update_mailchimp
		else
			activistMatch.update_mailchimp
		end
	end
end