class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :widget, index: true, foreign_key: true
      t.references :activist, index: true, foreign_key: true
      t.references :community, index: true, foreign_key: true
      t.jsonb :card_data
      t.string :status
      t.integer :period, default: 30
      t.integer :amount

      t.timestamps null: false
    end

    add_column :donations, :local_subscription_id, :integer
    add_foreign_key :donations, :subscriptions, column: :local_subscription_id
  end
end
