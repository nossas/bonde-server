class CreateFunctionConfiguration < ActiveRecord::Migration
  def change
    def  up
      execute %Q{
        create or replace function public.configuration(text)
        returns text
        language sql
        AS $$
            select value from public.configurations where name = $1;
        $$;
      }
    end

    def down
      execute %Q{
        drop funtion public.configuration(text)
      }
    end
  end
end
