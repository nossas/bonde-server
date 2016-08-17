class ActivistPressureSerializer < ActiveModel::Serializer
  attributes :id, :activist_id, :widget_id, :created_at, :updated_at, :count

  def count
    ActivistPressure.where(widget_id: object.widget_id).count
  end
end
