class CreateSubscriptionTransitions < ActiveRecord::Migration
  def change
    create_table :subscription_transitions do |t|
      t.string :to_state, null: false
      t.json :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :subscription_id, null: false
      t.boolean :most_recent, null: false
      t.timestamps null: false
    end

    add_index(:subscription_transitions,
              [:subscription_id, :sort_key],
              unique: true,
              name: "index_subscription_transitions_parent_sort")
    add_index(:subscription_transitions,
              [:subscription_id, :most_recent],
              unique: true,
              where: 'most_recent',
              name: "index_subscription_transitions_parent_most_recent")
  end
end
