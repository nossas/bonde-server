class RemoveReferenceFromActivists < ActiveRecord::Migration
  def change
    remove_reference :activists, :address, index: true, foreign_key: true
  end
end
