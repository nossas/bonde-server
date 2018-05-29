class UpdatesDonationWhenSubscriptionNil < ActiveRecord::Migration
  def change
    execute %Q{
update donations set subscription = true where local_subscription_id is not null;
update donations set subscription = false where local_subscription_id is null;
}
  end
end
