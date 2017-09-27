class AddMobilizationReferencesToActivistTags < ActiveRecord::Migration
  def change
    add_column :activist_tags, :mobilization_id, :integer, foreign_key: true
  end
end
