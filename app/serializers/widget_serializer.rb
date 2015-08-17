class WidgetSerializer < ActiveModel::Serializer
  attributes :id, :block_id, :kind, :settings, :sm_size, :md_size, :lg_size, :created_at, :updated_at

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
end
