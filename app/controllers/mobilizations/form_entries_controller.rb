require 'csv'

class Mobilizations::FormEntriesController < ApplicationController
  respond_to :json
  after_action :verify_policy_scoped, only: %i[]

  def index
    ###
    # TODO: Organizar endpoints de forma aninhada exemplo:
    # Endpoint: /mobilizations/:mobilization_id/widgets/:widget_id/form_entries
    ###
    authorize parent, :authenticated?
    @form_entries = parent.form_entries

    if params[:widget_id].present?
      @form_entries = @form_entries.where(widget_id: params[:widget_id])
      if (widget = policy_scope(Widget).find(params[:widget_id]))
        widget.update_attribute :exported_at, DateTime.now
      end
    end
    @form_entries = @form_entries.order(:id)
    @form_entries = disjoint_fields if params[:INFO] == 'disjoint_fields'

    respond_with do |format|
      format.html { render json: @form_entries }
      format.json { render json: @form_entries }

      format.csv do
        send_data to_csv(@form_entries), type: Mime::CSV, disposition: "attachment; filename=form_entries_#{DateTime.now.to_i}_#{parent.community.name.parameterize}_#{parent.id}.csv"
      end
    end
  end

  def create
    @form_entry = FormEntry.new(form_entry_params)
    authorize @form_entry
    (render json: @form_entry.errors, status: 400 and return) unless @form_entry.validate
    @form_entry.save!
    render json: @form_entry
  end

  private

  def to_csv data
    fst =  data.first
    if fst.is_a? Hash
      CSV.generate(headers: true) do |csv|
        csv << fst.keys

        data.each do |fe|
          csv << fe
        end
      end
    else
      CSV.generate(headers: true) do |csv|
        csv << fst.attributes.keys

        data.each do |fe|
          csv << fe.attributes.values
        end
      end
    end
  end

  def form_entry_params
    params.require(:form_entry).permit(*policy(@form_entry || FormEntry.new).permitted_attributes)
  end

  def parent
    @mobilization ||= policy_scope(Mobilization).find params[:mobilization_id]
  end

  def disjoint_fields 
    @form_entries.map do |form_entry|
      custom_fields = JSON.parse(form_entry.fields).map{|f| [f['label'], f['value']] }.to_h
      fixed_attributes = form_entry.attributes
      fixed_attributes.delete 'fields'
      fixed_attributes.delete 'synchronized'
      fixed_attributes['requester'] = current_user.id
      Hash[fixed_attributes.merge(custom_fields).sort.to_h]
    end
  end
end
