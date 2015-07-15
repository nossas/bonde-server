class AddFontSetToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :font_set, :string
  end
end
