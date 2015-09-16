module Mailchimpable
  def find_or_create_segment_by_name(segment_name)
    segments = api_client.lists.static_segments({id: ENV['MAILCHIMP_LIST_ID']})

    segments.each do |segment|
      if /#{segment_name}/.match(segment["name"])
        return segment
      end
    end

    return api_client.lists.static_segment_add({
      id: ENV['MAILCHIMP_LIST_ID'],
      name: segment_name
    })
  end

  def subscribe_to_list(email, merge_vars)
    api_client.lists.subscribe({
      id: ENV['MAILCHIMP_LIST_ID'],
      email: {email: email},
      merge_vars: merge_vars,
      double_optin: false,
      update_existing: true
    })
  end

  def subscribe_to_segment(segment_id, email)
    api_client.lists.static_segment_members_add({
      id: ENV['MAILCHIMP_LIST_ID'],
      seg_id: segment_id,
      batch: [{email: email}]
    })
  end

  def api_client
    return Gibbon::API.new
  end
end
