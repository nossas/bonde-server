class CreateDonationTransitions < ActiveRecord::Migration
  def change
    create_table :donation_transitions do |t|
      t.string :to_state, null: false
      t.jsonb :metadata, default: "{}"
      t.integer :sort_key, null: false
      t.integer :donation_id, null: false
      t.boolean :most_recent, null: false
      t.timestamps null: false
    end

    add_index(:donation_transitions,
              [:donation_id, :sort_key],
              unique: true,
              name: "index_donation_transitions_parent_sort")
    add_index(:donation_transitions,
              [:donation_id, :most_recent],
              unique: true,
              where: 'most_recent',
              name: "index_donation_transitions_parent_most_recent")
  end
end
