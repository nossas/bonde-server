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
    @form_entries = @form_entries.where(widget_id: params[:widget_id]) if params[:widget_id].present?
    render json: @form_entries.to_json
  end

  def create
    @form_entry = FormEntry.new(form_entry_params)
    authorize @form_entry
    @form_entry.save!
    render json: @form_entry
  end

  private

  def form_entry_params
    params.require(:form_entry).permit(*policy(@form_entry || FormEntry.new).permitted_attributes)
  end

  def parent
    @mobilization ||= policy_scope(Mobilization).find params[:mobilization_id]
  end
end
