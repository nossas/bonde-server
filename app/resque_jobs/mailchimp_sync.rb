class MailchimpSync
	@queue = :mailchimp_synchro

	def self.perform(id, queue) 
		if queue == 'formEntry'
			self.perform_with_formEntry(id)
		elsif queue == 'activist_pressure'
			self.perform_with_activist_pressure(id)
		elsif queue == 'activist_match'
			self.perform_with_activist_match(id)
		end
	end

	def self.create_segment_if_necessary(widget)
		if ( not widget.mailchimp_segment_id )
			widget.create_mailchimp_segment
		end
	end


	def self.perform_with_formEntry(form_entry_id)
		formEntry = FormEntry.find(form_entry_id)

		widget = formEntry.widget 
		if (widget) and ( not formEntry.synchronized )
			self.create_segment_if_necessary(formEntry.widget)
			formEntry.send_to_mailchimp
			formEntry.synchronized = true
			formEntry.save
		end
	end

	def self.perform_with_activist_pressure(activist_pressure_id)
		activistPressure = ActivistPressure.find(activist_pressure_id)
		widget = activistPressure.widget 
		if ( widget ) and ( widget.id )
			self.create_segment_if_necessary(activistPressure.widget)
			activistPressure.update_mailchimp
		end
	end

	def self.perform_with_activist_match(activist_pressure_id)
		activistMatch = ActivistMatch.find(activist_pressure_id)
		widget = activistMatch.widget 
		if ( widget )
			self.create_segment_if_necessary(widget)
			activistMatch.update_mailchimp
		end
	end
end