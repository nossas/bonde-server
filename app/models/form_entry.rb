class FormEntry < ActiveRecord::Base
  validates :widget, :fields, presence: true
  belongs_to :widget
end
