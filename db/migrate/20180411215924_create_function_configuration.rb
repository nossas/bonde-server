class CreateFunctionConfiguration < ActiveRecord::Migration
  def  up
    execute %Q{
        create or replace function public.configuration(name text)
        returns text
        language sql
        AS $$
            select value from public.configurations where name = $1;
        $$;
    }
  end

  def down
    execute %Q{
        drop funtion public.configuration(name text)
    }
  end
end
