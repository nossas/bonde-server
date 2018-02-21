class AddMissingGrantsWhenRebuildDatatabase < ActiveRecord::Migration
  def change
    execute %Q{
grant select, insert on notifications to common_user, admin, anonymous;
grant select on notification_templates to common_user, admin, anonymous; 
grant select, insert on notifications to common_user, admin, anonymous;
grant select, update, insert on users to common_user, admin, anonymous;
grant usage on sequence users_id_seq to anonymous, common_user, admin;
grant usage on sequence notifications_id_seq to anonymous, common_user, admin;
}
  end
end
