class BlockSerializer < ActiveModel::Serializer
    attributes :id, :mobilization_id, :created_at, :updated_at, :bg_class, :position, :hidden, :bg_image, :name, :menu_hidden

  class CompleteBlockSerializer < ActiveModel::Serializer
    attributes :id, :mobilization_id, :created_at, :updated_at, :bg_class, :position, :hidden, :bg_image, :name, :menu_hidden, :widgets_attributes

    def widgets_attributes
      object.widgets 
    end
  end
end