class AddCardIdAndSubscriptionToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :subscription, :boolean
    add_column :donations, :credit_card, :string
  end
end
