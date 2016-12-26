class AddRecipientToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :recipient, :jsonb
  end
end
