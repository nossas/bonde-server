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
		form_entry = FormEntry.find(form_entry_id)

		widget = form_entry.widget 
		if (widget) and ( not form_entry.synchronized )
			self.create_segment_if_necessary(form_entry.widget)
			form_entry.send_to_mailchimp
			form_entry.synchronized = true
			form_entry.save
		end
	end

	def self.perform_with_activist_pressure(activist_pressure_id)
		activist_pressure = ActivistPressure.find(activist_pressure_id)
		widget = activist_pressure.widget 
		if ( widget ) and ( widget.id ) and ( not activist_pressure.synchronized )
			self.create_segment_if_necessary(activist_pressure.widget)
			activist_pressure.update_mailchimp
		end
	end

	def self.perform_with_activist_match(activist_match_id)
		activist_match = ActivistMatch.find(activist_match_id)
		widget = activist_match.widget 
		if ( widget ) and ( widget.id ) and ( not activist_match.synchronized )
			self.create_segment_if_necessary(widget)
			activist_match.update_mailchimp
		end
	end
end