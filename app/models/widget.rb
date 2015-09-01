class Widget < ActiveRecord::Base
  validates :sm_size, :md_size, :lg_size, :kind, presence: true
  belongs_to :block
  has_one :mobilization, through: :block
  has_many :form_entries
  store_accessor :settings

  def as_json(options = {})
    WidgetSerializer.new(self, {root: false})
  end
end
