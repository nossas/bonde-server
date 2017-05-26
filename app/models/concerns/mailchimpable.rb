module Mailchimpable
  class MailchimpableException < StandardError
    def initialize standard_error, message
      @message = "#{message} +\r\n#{standard_error.message}"
    end

    def to_s
      @message
    end
  end

  def create_segment(segment_name)
    api_client.lists(mailchimp_list_id).segments.create(body: {
      name: segment_name,
      static_segment: []
    })
  end

  def status_on_list email
    begin
      member = api_client.lists(mailchimp_list_id).members(create_hash email).retrieve
      member.body['status'].to_sym
    rescue Gibbon::MailChimpError => e
      if e.to_s =~ /the server responded with status 404/
        :not_registred
      else
        raise MailchimpableException.new(e, "status on list list_id: #{mailchimp_list_id}, email: '#{email}'")
      end
    end
  end


  def subscribe_to_list(email, merge_vars, options = {})
    begin
      if options[:update_existing]
        api_client.lists(mailchimp_list_id).members(create_hash email).upsert(body: create_body(email, merge_vars: merge_vars, options: options))
      else
        api_client.lists(mailchimp_list_id).members.create(body: create_body(email, merge_vars: merge_vars, options: options))
      end
    rescue StandardError => e
      raise Mailchimpable::MailchimpableException.new(e, 
        "List signature error:\nParams: (email: '#{email}', merge_vars: '#{merge_vars}', options: '#{options}')\nError:#{e}" ) unless e.message =~ /.*title="Member Exists".*/
    end
  end


  def subscribe_to_segment(segment_id, email)
    begin
      api_client.lists(mailchimp_list_id).segments(segment_id).members.create(body: {
        email_address: email
      }) if segment_id
    rescue StandardError => e
      raise MailchimpableException.new( e, "Subscribe_to_segment error:\nParams: (segment_id: '#{segment_id}', (email: '#{email}')\nError:#{e}" )
    end
  end


  def unsubscribe_to_segment(segment_id, email)
    begin
      if segment_id
        api_client.lists(mailchimp_list_id).segments(segment_id).members(create_hash email).delete 
        true
      end
    rescue StandardError => e
      raise MailchimpableException.new( e, "Unsubscribe_to_segment error:\nParams: (segment_id: '#{segment_id}', (email: '#{email}')\nError:#{e}" )
    end
  end


  def update_member(email, options)
    begin
      api_client.lists(mailchimp_list_id).members(Digest::MD5.hexdigest(email.downcase)).update(body: create_body(email, options: options))
    rescue StandardError => e
      raise MailchimpableException.new(e, "update_member error:\nParams: (email: '#{email}', options: '#{options}')\nError:#{e}")
    end
  end

  def groupings
    if community and community.mailchimp_group_id  and (not community.mailchimp_group_id.empty?)
      { "#{community.mailchimp_group_id}" => true }
    end
  end

  private

  def mailchimp_list_id
    return_mailchimp_list_id = community.try(:mailchimp_list_id)
    return_mailchimp_list_id = ENV['MAILCHIMP_LIST_ID'] if ( not return_mailchimp_list_id ) || ( return_mailchimp_list_id.empty? )
    return_mailchimp_list_id
  end

  def mailchimp_group_id
    return_mailchimp_group_id = community.try(:mailchimp_group_id)
    return_mailchimp_group_id = ENV['MAILCHIMP_GROUP_ID'] if  ( not return_mailchimp_group_id ) || ( return_mailchimp_group_id.empty? )
    return_mailchimp_group_id
  end

  def mailchimp_api_key
    return_mailchimp_api_key = community.try(:mailchimp_api_key)
    return_mailchimp_api_key = ENV['MAILCHIMP_API_KEY'] if ( not return_mailchimp_api_key ) || ( return_mailchimp_api_key.empty? )
    return_mailchimp_api_key
  end

  def api_client
    Gibbon::Request.new(api_key: mailchimp_api_key)
  end

  def create_body email, merge_vars: nil, options: {}    
    body = { }
    if merge_vars
      body = {
        email_address: email,
        status: :subscribed
      }
      body[:merge_fields] = merge_vars if merge_vars
    end
    body[:interests] = options[:groupings] if options[:groupings]
    body
  end

  private

  def create_hash email
    Digest::MD5.hexdigest(email.downcase) 
  end
end