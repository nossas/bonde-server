class MailchimpSyncWorker
  include Sidekiq::Worker
  sidekiq_options queue: :mailchimp_synchro

  def perform(id, queue) 
    action_widget = nil
    if queue == 'formEntry'
      action_widget = FormEntry.find id
    elsif queue == 'activist_pressure'
      action_widget = ActivistPressure.find id
    elsif queue == 'activist_match'
      action_widget = ActivistMatch.find id
    elsif queue == 'donation'
      action_widget = Donation.find id
    elsif queue == 'subscription'
      perform_subscription( Subscription.find id ) and return
    end
    perform_with action_widget if action_widget
  end

  def create_segment_if_necessary(widget)
    if ( not widget.mailchimp_segment_id )
      widget.create_mailchimp_segment
    end
  end

  def perform_with action_widget
    widget = action_widget.widget 
    if ( widget ) and ( not action_widget.synchronized )
      create_segment_if_necessary(widget)
      action_widget.update_mailchimp
      update_status action_widget
    end
  end

  def perform_subscription subscription
    return if (subscription.current_state =~ /(un)?paid|canceled/.nil?) || (subscription.synchronized) 
    if subscription.current_state =~ /unpaid|canceled/
      subscription.mailchimp_remove_from_active_donators
    else
      subscription.mailchimp_add_active_donators
    end
    update_status subscription
  end

  def update_status record
    record.synchronized = true
    record.save! validate: false
  end
end
