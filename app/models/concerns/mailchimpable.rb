module Mailchimpable
  def create_segment(segment_name)
    return api_client.lists.static_segment_add({
      id: ENV['MAILCHIMP_LIST_ID'],
      name: segment_name
    })
  end

  def subscribe_to_list(email, merge_vars, options = {})
    begin
      api_client.lists.subscribe({
        id: ENV['MAILCHIMP_LIST_ID'],
        email: {email: email},
        merge_vars: merge_vars,
        double_optin: options[:double_optin] || false,
        update_existing: options[:update_existing] || false
      })
    rescue StandardError => e
      logger.error(e)
    end
  end

  def subscribe_to_segment(segment_id, email)
    begin
      api_client.lists.static_segment_members_add({
        id: ENV['MAILCHIMP_LIST_ID'],
        seg_id: segment_id,
        batch: [{email: email}]
      })
    rescue StandardError => e
      logger.error(e)
    end
  end

  def update_member(email, merge_vars)
    begin
      api_client.lists.update_member({
        id: ENV['MAILCHIMP_LIST_ID'],
        email: {email: email},
        merge_vars: merge_vars,
        replace_interests: false
      })
    rescue StandardError => e
      logger.error(e)
    end
  end

  def mailchimp_api_key
    community.try(:mailchimp_api_key) || ENV['MAILCHIMP_API_KEY']
  end

  def api_client
    @mailchimp_api_client ||= Gibbon::API.new(mailchimp_api_key)
  end
end
