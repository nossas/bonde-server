class EnsurePostgraphqlRoles < ActiveRecord::Migration
  def change
    execute %Q{
grant usage on schema public to postgraphql;
grant usage on schema public to admin;
grant usage on schema public to common_user;
}
  end
end
