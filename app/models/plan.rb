class Plan < ActiveRecord::Base
  validates :name, :plan_id, :amount, :days, presence: true
end
