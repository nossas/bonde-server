class FormEntry < ActiveRecord::Base
  validates :widget, :fields, presence: true
  belongs_to :widget

  after_create :update_mailchimp

  def update_mailchimp
    fields = JSON.parse(self.fields)
    email = nil
    first_name = nil
    last_name = nil
    phone = nil
    fields.each do |field|
      if !email && field['kind'] == 'email'
        email = field['value']
      elsif field['label'] && !first_name && ['nome'].include?(field['label'].downcase)
        first_name = field['value']
      elsif field['label'] && !last_name && ['sobrenome', 'sobre-nome', 'sobre nome'].include?(field['label'].downcase)
        last_name = field['value']
      elsif field['label'] && !phone && ['telefone', 'fone', 'celular'].include?(field['label'].downcase)
        phone = field['value']
      end
    end
    merge_vars = {}
    merge_vars[:FNAME] = first_name if first_name
    merge_vars[:LNAME] = last_name if last_name
    merge_vars[:PHONE] = phone if phone
    if email
      begin
        mailchimp = Gibbon::API.new
        mailchimp.lists.subscribe({id: ENV['MAILCHIMP_LIST_ID'], email: {email: email}, merge_vars: merge_vars, double_optin: false, update_existing: true})
        mobilization = self.widget.mobilization
        segment_name = "M#{mobilization.id}A#{self.widget_id} - #{mobilization.name[0..89]}"
        segments = mailchimp.lists.static_segments({id: ENV['MAILCHIMP_LIST_ID']})
        segments.each do |segment|
          if /#{segment_name}/.match(segment["name"])
            @segment = segment
            break
          end
        end
        unless @segment
          @segment = mailchimp.lists.static_segment_add({
            id: ENV['MAILCHIMP_LIST_ID'],
            name: segment_name
          })
        end
        if @segment
          mailchimp.lists.static_segment_members_add({
            id: ENV['MAILCHIMP_LIST_ID'],
            seg_id: @segment["id"],
            batch: [{email: email}]
          })
        end
      rescue Exception => e
        logger.fatal e
      end
    end
  end
end
