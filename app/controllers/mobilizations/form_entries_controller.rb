class Mobilizations::FormEntriesController < ApplicationController
  respond_to :json
  after_action :verify_policy_scoped, only: %i[]

  def create
    @form_entry = FormEntry.new(form_entry_params)
    authorize @form_entry
    @form_entry.save
    render json: @form_entry
  end

  private

  def form_entry_params
    params.require(:form_entry).permit(*policy(@form_entry || FormEntry.new).permitted_attributes)
  end
end
