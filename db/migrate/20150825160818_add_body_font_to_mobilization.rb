class AddBodyFontToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :body_font, :string
  end
end
