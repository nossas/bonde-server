class Organization < ActiveRecord::Base
  validates :name, :city, presence: true, uniqueness: true
end
