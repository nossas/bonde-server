class AddUniquenessToSlugFromMobilization < ActiveRecord::Migration
  def up
    add_index :mobilizations, :slug, unique: true
  end

  def down
    remove_index :mobilizations, :slug
  end
end
