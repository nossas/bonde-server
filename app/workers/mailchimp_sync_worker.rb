class MailchimpSyncWorker
  include Sidekiq::Worker
  sidekiq_options queue: :mailchimp_synchro

  def perform(id, queue) 
    if queue == 'formEntry'
      perform_with_formEntry(id)
    elsif queue == 'activist_pressure'
      perform_with_activist_pressure(id)
    elsif queue == 'activist_match'
      perform_with_activist_match(id)
    elsif queue == 'donation'
      perform_with_donation(id)
    end
  end

  def create_segment_if_necessary(widget)
    if ( not widget.mailchimp_segment_id )
      widget.create_mailchimp_segment
    end
  end


  def perform_with_formEntry(form_entry_id)
    form_entry = FormEntry.find(form_entry_id)

    widget = form_entry.widget 
    if (widget) and ( not form_entry.synchronized )
      create_segment_if_necessary(form_entry.widget)
      form_entry.update_mailchimp
      update_status form_entry
    end
  end

  def perform_with_activist_pressure(activist_pressure_id)
    activist_pressure = ActivistPressure.find(activist_pressure_id)
    widget = activist_pressure.widget 
    if ( widget ) and ( not activist_pressure.synchronized )
      create_segment_if_necessary(activist_pressure.widget)
      activist_pressure.update_mailchimp
      update_status activist_pressure
    end
  end

  def perform_with_activist_match(activist_match_id)
    activist_match = ActivistMatch.find(activist_match_id)
    widget = activist_match.widget 
    if ( widget ) and ( not activist_match.synchronized )
      create_segment_if_necessary(widget)
      activist_match.update_mailchimp
      update_status activist_match
    end
  end

  def perform_with_donation(donation_id)
    donation = Donation.find(donation_id)
    widget = donation.widget 
    if ( widget ) and ( not donation.synchronized )
      create_segment_if_necessary(widget)
      donation.update_mailchimp
      update_status donation
    end
  end

  def update_status record
    record.synchronized = true
    record.save! validate: false
  end

end
