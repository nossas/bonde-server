class AddPaymentMethodToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :payment_method, :text, null: false
  end
end
