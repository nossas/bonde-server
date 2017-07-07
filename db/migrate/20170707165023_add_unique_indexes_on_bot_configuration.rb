class AddUniqueIndexesOnBotConfiguration < ActiveRecord::Migration
  def up
    execute %Q{
create unique index uniq_m_page_access_token_idx on public.facebook_bot_configurations(messenger_page_access_token);
}
  end

  def down
    execute %Q{
drop unique index uniq_m_page_access_token_idx;
}
  end
end
