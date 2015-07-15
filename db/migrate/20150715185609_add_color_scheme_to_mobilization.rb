class AddColorSchemeToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :color_scheme, :string
  end
end
