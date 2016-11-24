class AddCityToActivist < ActiveRecord::Migration
  def change
    add_column :activists, :city, :string
  end
end
