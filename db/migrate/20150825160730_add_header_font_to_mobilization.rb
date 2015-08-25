class AddHeaderFontToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :header_font, :string
  end
end
