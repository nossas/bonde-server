class CommunityActivist < ActiveRecord::Base
  belongs_to :community
  belongs_to :activist
end
