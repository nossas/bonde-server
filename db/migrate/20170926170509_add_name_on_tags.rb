class AddNameOnTags < ActiveRecord::Migration
  def change
    add_column(:tags, :label, :text)
  end
end
