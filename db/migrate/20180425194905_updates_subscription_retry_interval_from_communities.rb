class UpdatesSubscriptionRetryIntervalFromCommunities < ActiveRecord::Migration
  def up
    execute %Q{
      update communities set subscription_retry_interval = 7;
    }
  end

  def down
    execute %Q{
      update communities set subscription_retry_interval = 3;
    }
  end
end
