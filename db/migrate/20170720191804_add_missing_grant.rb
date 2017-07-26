class AddMissingGrant < ActiveRecord::Migration
  def change
    execute %Q{
grant select on postgraphql.activists to common_user, admin;
}
  end
end
