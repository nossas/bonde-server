class RemovesDuplicatesCommunitiesFromUser < ActiveRecord::Migration
  def change
    User.all.each do |user|
      execute %Q{ delete from community_users
    where id in (
        select id from (
            SELECT  row_number() over (partition by community_id),
                id,
                community_id,
                user_id
            FROM community_users
        WHERE user_id = #{user.id}
             ) t
        where t.row_number > 1
    );
      }
    end
  end
end
