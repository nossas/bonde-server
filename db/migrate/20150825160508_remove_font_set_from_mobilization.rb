class RemoveFontSetFromMobilization < ActiveRecord::Migration
  def change
    remove_column :mobilizations, :font_set, :string
  end
end
