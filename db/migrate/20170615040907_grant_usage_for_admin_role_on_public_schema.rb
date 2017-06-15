class GrantUsageForAdminRoleOnPublicSchema < ActiveRecord::Migration
  def change
    execute %Q{grant usage on schema public to admin;}
  end
end
