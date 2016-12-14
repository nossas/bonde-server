class ImportUsersIntoCommunities < ActiveRecord::Migration
  def up
    execute %Q{
      insert into community_users(user_id, community_id, role, created_at, updated_at)
        select distinct
          m.community_id,
          m.user_id,
          1 as role,
          current_timestamp,
          current_timestamp
        from 
          mobilizations m
        where ( m.community_id is not null ) and ( m.user_id is not null )
    }
  end
end
