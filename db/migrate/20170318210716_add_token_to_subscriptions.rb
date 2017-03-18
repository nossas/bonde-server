class AddTokenToSubscriptions < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    add_column :subscriptions, :token, :uuid, default: 'uuid_generate_v4()'
  end
end
