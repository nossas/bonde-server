class MobilizationActivist < ActiveRecord::Base
  belongs_to :mobilization
  belongs_to :activist
end
