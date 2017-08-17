class AddedAbstractTriggerToInsertWhenHasWidget < ActiveRecord::Migration
  def up
    execute %Q{
create or replace function public.generate_activists_from_generic_resource_with_widget() returns trigger
    language plpgsql
    as $$
        declare
            v_mobilization public.mobilizations;
        begin
            IF TG_TABLE_NAME in ('subscriptions', 'form_entries', 'donations', 'activist_pressures')
                AND NEW.activist_id is not null AND NEW.widget_id is not null THEN

                select distinct(m.*) from mobilizations m
                    join blocks b on b.mobilization_id = m.id
                    join widgets w on w.block_id = b.id
                    where w.id = NEW.widget_id
                    into v_mobilization;

                if not exists(select true
                    from community_activists
                    where community_id = v_mobilization.community_id and activist_id = NEW.activist_id) then
                    insert into community_activists (community_id, activist_id, created_at, updated_at)
                        values (v_mobilization.community_id, NEW.activist_id, now(), now());
                end if;

                if not exists(select true
                    from mobilization_activists
                    where mobilization_id = v_mobilization.id and activist_id = NEW.activist_id) then
                    insert into mobilization_activists (mobilization_id, activist_id, created_at, updated_at)
                        values (v_mobilization.id, NEW.activist_id, now(), now());
                end if;

            END IF;
            return NEW;
        end;
    $$;
comment on function public.generate_activists_from_generic_resource_with_widget() is 'insert a row on mobilization_activists and community_activists linking from NEW.activist_id / widget_id';

create trigger generate_activists_from_generic_resource_with_widget
    after insert or update on form_entries
    for each row execute procedure public.generate_activists_from_generic_resource_with_widget();

create trigger generate_activists_from_generic_resource_with_widget
    after insert or update on activist_pressures
    for each row execute procedure public.generate_activists_from_generic_resource_with_widget();

create trigger generate_activists_from_generic_resource_with_widget
    after insert or update on donations
    for each row execute procedure public.generate_activists_from_generic_resource_with_widget();

create trigger generate_activists_from_generic_resource_with_widget
    after insert or update on subscriptions
    for each row execute procedure public.generate_activists_from_generic_resource_with_widget();
}
  end

  def down
    execute %Q{
drop function  public.generate_activists_from_generic_resource_with_widget() cascade;
}
  end
end
