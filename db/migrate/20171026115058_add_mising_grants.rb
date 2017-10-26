class AddMisingGrants < ActiveRecord::Migration
  def change
    execute %Q{
grant usage on sequence public.activists_id_seq to common_user, admin;
}
  end
end
