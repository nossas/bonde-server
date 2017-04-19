class AddCommentToDnsRecords < ActiveRecord::Migration
  def change
    add_column :dns_records, :comment, :string
  end
end
