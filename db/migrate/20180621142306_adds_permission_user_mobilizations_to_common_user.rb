class AddsPermissionUserMobilizationsToCommonUser < ActiveRecord::Migration
  def up
    execute %Q{
GRANT SELECT ON public.mobilizations TO common_user, admin;
GRANT SELECT ON postgraphql.user_mobilizations TO common_user, admin;
}
  end

  def down
    execute %Q{
REVOKE SELECT ON postgraphql.user_mobilization TO common_user, admin;
}
  end
end
