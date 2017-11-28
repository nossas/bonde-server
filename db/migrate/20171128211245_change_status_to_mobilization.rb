class ChangeStatusToMobilization < ActiveRecord::Migration
  def up
    remove_column :mobilizations, :status

    execute <<-SQL
      DROP TYPE status_mobilization;
      CREATE TYPE status_mobilization AS ENUM ('active', 'archived');
    SQL

    add_column :mobilizations, :status, :status_mobilization, default: 'active'
  end

  def down
    remove_column :mobilizations, :status

    execute <<-SQL
      DROP TYPE status_mobilization;
    SQL
  end
end
