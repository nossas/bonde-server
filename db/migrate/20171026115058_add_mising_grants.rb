class AddMisingGrants < ActiveRecord::Migration
  def change
    execute %Q{
grant usage on sequence activists_id_seq to common_user, postgraphql, admin;;
}
  end
end
