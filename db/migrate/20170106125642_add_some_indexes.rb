class AddSomeIndexes < ActiveRecord::Migration
  def change
    execute %Q{
create index if not exists idx_mobilizations_custom_domain on mobilizations(custom_domain);
create index if not exists idx_mobilizations_slug on mobilizations(slug);

create index if not exists ids_blocks_mob_id on blocks(mobilization_id);

create index if not exists ids_widgets_block_id on widgets(block_id);
create index if not exists ids_widgets_kind on widgets(kind);
create index if not exists ordasc_widgets on widgets(id ASC);
}
  end
end
