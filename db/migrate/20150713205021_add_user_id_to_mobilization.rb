class AddUserIdToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :user_id, :integer
  end
end
