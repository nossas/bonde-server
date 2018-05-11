class ChangeDefaultValueFromSubscriptionRetryInterval < ActiveRecord::Migration
  def up
    execute %Q{
      ALTER TABLE ONLY communities ALTER COLUMN subscription_retry_interval SET DEFAULT 7;
    }
  end

  def down
    execute %Q{
      ALTER TABLE ONLY communities ALTER COLUMN subscription_retry_interval SET DEFAULT 3;
    }
  end
end
