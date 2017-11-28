class AddsStatusToMobilization < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE TYPE status_mobilization AS ENUM ('draft', 'active', 'archived');
    SQL

    add_column :mobilizations, :status, :status_mobilization, default: 'draft'
  end

  def down
    remove_column :mobilizations, :status

    execute <<-SQL
      DROP TYPE status_mobilization;
    SQL
  end
end
