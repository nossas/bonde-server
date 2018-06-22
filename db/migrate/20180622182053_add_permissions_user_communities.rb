class AddPermissionsUserCommunities < ActiveRecord::Migration
  def up
    execute %Q{
grant select on postgraphql.user_communities to common_user, admin;
}
  end

  def down
    execute %Q{
revoke select on postgraphql.user_communities to common_user, admin;
}
  end
end
