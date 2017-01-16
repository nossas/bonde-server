class AddSynchronizedToActivistMatch < ActiveRecord::Migration
  def change
    add_column :activist_matches, :synchronized, :boolean
  end
end
