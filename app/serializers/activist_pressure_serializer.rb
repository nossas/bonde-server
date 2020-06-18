class ActivistPressureSerializer < ActiveModel::Serializer
  attributes :id, :activist_id, :widget_id, :created_at, :updated_at, :count

  def count
    if object.widget_id.to_s.eql?("62189")
      ActivistPressure.where(widget_id: object.widget_id).count + ActivistPressure.where(widget_id: 62347).count
    else
      ActivistPressure.where(widget_id: object.widget_id).count
    end
  end
end
