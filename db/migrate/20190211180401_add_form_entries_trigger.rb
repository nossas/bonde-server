class AddFormEntriesTrigger < ActiveRecord::Migration
  def up
    execute %Q{
      CREATE OR REPLACE FUNCTION public.notify_form_entries_trigger() RETURNS TRIGGER LANGUAGE PLPGSQL AS $$
        BEGIN

          perform pg_notify('form_entries_channel',
            pgjwt.sign(
              row_to_json(NEW),
              public.configuration('jwt_secret'),
              'HS512'
            )
          );

          RETURN NEW;
        END;
      $$;

      -- Trigger só irá disparar quando houver atualizando em um desses 3 widgets
      -- ATENÇÃO: A remoção desses widgets interferem no funcionamento correto da
      -- integração com o Zendesk.
      --
      -- MSR: 16850 // Psicologas: 17628 // Advogadas: 17633
      CREATE TRIGGER watched_create_form_entries_trigger AFTER
      INSERT
      OR
      UPDATE ON public.form_entries
      FOR EACH ROW
      WHEN (NEW.widget_id in (16850, 17628, 17633))
      EXECUTE PROCEDURE public.notify_form_entries_trigger();
  }
  end

  def down
    execute %Q{
      DROP TRIGGER watched_create_form_entries_trigger ON public.form_entries;
      DROP FUNCTION public.notify_form_entries_trigger();
    }
  end
end
