class AddFaviconToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :favicon, :string
  end
end
