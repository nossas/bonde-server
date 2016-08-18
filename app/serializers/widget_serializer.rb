class WidgetSerializer < ActiveModel::Serializer
  attributes :id, :block_id, :kind, :settings, :sm_size, :md_size, :lg_size,
    :form_entries_count, :donations_count, :created_at, :updated_at,
    :action_community, :action_opportunity, :exported_at, :match_list, :pressure_count

  def match_list
    object.matches
  end

  #
  # Find a way to remove these attributes depending on widget kind.
  # e.g. Is not necessary to have `pressure_count` if widget kind is match.
  #
  def pressure_count
    object.activist_pressures.count
  end

  def settings
    return unless object.settings
    json = {}
    object.settings.keys.each do |key|
      if key == 'fields'
        json[key] = JSON.parse(object.settings[key])
      else
        json[key] = object.settings[key]
      end
    end
    json
  end

  def form_entries_count
    object.form_entries.count
  end

  def donations_count
    object.donations.count
  end

  def action_opportunity
    object.form?
  end
end
