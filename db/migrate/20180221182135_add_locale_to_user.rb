class AddLocaleToUser < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function public.locale_names()
returns text[] language sql
immutable as $$
    select '{pt-BR, es, en}'::text[];
$$;

alter table users
    add column locale text not null default 'pt-BR',
    add constraint localechk CHECK (locale = ANY(public.locale_names()));

alter table notification_templates
    add column locale text not null default 'pt-BR',
    add constraint localechk CHECK (locale = ANY(public.locale_names()));

create unique index notification_templates_label_uniq_idx on notification_templates(community_id, label, locale);
}
  end

  def down
    execute %Q{

drop index public.notification_templates_label_uniq_idx;
alter table notification_templates
  drop column locale;
alter table users
  drop column locale;
drop function public.locale_names();
}
  end
end
