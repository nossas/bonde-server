class BlockSerializer < ActiveModel::Serializer
    attributes :id, :mobilization_id, :created_at, :updated_at, :bg_class, :position, :hidden, :bg_image, :name, :menu_hidden, :deleted_at

  class CompleteBlockSerializer < ActiveModel::Serializer
    attributes :id, :mobilization_id, :created_at, :updated_at, :bg_class, :position, :hidden, :bg_image, :name, :menu_hidden, :widgets_attributes, :deleted_at

    def widgets_attributes
      object.widgets.order(:id) 
    end
  end
end