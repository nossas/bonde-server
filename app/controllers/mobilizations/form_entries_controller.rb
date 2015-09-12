class Mobilizations::FormEntriesController < ApplicationController
  respond_to :json
  after_action :verify_policy_scoped, only: %i[]

  def create
    @form_entry = FormEntry.new(form_entry_params)
    authorize @form_entry
    @form_entry.save!
    fields = JSON.parse(@form_entry.fields)
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
        mobilization = @form_entry.widget.mobilization
        segments = mailchimp.lists.static_segments({id: ENV['MAILCHIMP_LIST_ID']})
        segments.each do |segment|
          if /\A##{mobilization.id} - .+/.match(segment["name"])
            @segment = segment
            break
          end
        end
        unless @segment
          @segment = mailchimp.lists.static_segment_add({id: ENV['MAILCHIMP_LIST_ID'], name: "##{mobilization.id} - #{mobilization.name}"})
        end
        if @segment
          mailchimp.lists.static_segment_members_add({id: ENV['MAILCHIMP_LIST_ID'], seg_id: @segment["id"], batch: [{email: email}]})
        end
      rescue
      end
    end
    render json: @form_entry
  end

  private

  def form_entry_params
    params.require(:form_entry).permit(*policy(@form_entry || FormEntry.new).permitted_attributes)
  end
end
