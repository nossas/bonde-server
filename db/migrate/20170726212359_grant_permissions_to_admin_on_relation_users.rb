class GrantPermissionsToAdminOnRelationUsers < ActiveRecord::Migration
  def up
    execute %Q{
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users TO admin;
}
  end

  def down
    execute %Q{
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.users FROM admin;
}
  end
end
