class ChangeFastNameToLastNameIntoActivists < ActiveRecord::Migration
    def change
         rename_column :activists, :fast_name, :last_name
    end
end
