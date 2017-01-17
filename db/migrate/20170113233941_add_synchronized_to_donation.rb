class AddSynchronizedToDonation < ActiveRecord::Migration
  def change
    if column_exists?(:donations, :synchronized)
      # Since there was this field on production, and we didn't know why or when it was introduced, we decided to rename it
      # to maintain it's data
      rename_column(:donations, :synchronized, :old_synch)
    end
    add_column :donations, :synchronized, :boolean
  end
end
