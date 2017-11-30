class AdjustGenerateActivistsToBuildProfileOnCommunityActivists < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION public.generate_activists_from_generic_resource_with_widget()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
        declare
            v_mobilization public.mobilizations;
            v_profile_data json;
        begin
            IF TG_TABLE_NAME in ('subscriptions', 'form_entries', 'donations', 'activist_pressures')
                AND NEW.activist_id is not null AND NEW.widget_id is not null THEN

                select distinct(m.*) from mobilizations m
                    join blocks b on b.mobilization_id = m.id
                    join widgets w on w.block_id = b.id
                    where w.id = NEW.widget_id
                    into v_mobilization;
                
                select row_to_json(activists.*) from activists where id = NEW.activist_id
                    into v_profile_data;

                IF v_mobilization.id IS NOT NULL THEN
                    if not exists(select true
                        from community_activists
                        where community_id = v_mobilization.community_id and activist_id = NEW.activist_id) then
                        insert into community_activists (community_id, activist_id, created_at, updated_at, profile_data)
                            values (v_mobilization.community_id, NEW.activist_id, now(), now(), v_profile_data::jsonb);
                    end if;

                    if not exists(select true
                        from mobilization_activists
                        where mobilization_id = v_mobilization.id and activist_id = NEW.activist_id) then
                        insert into mobilization_activists (mobilization_id, activist_id, created_at, updated_at)
                            values (v_mobilization.id, NEW.activist_id, now(), now());
                    end if;
                END IF;

            END IF;
            return NEW;
        end;
    $function$

}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION public.generate_activists_from_generic_resource_with_widget()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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

                IF v_mobilization.id IS NOT NULL THEN
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

            END IF;
            return NEW;
        end;
    $function$;

}
  end
end
