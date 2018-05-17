class AddMissingPermissionsToPostgres < ActiveRecord::Migration
  def change
    execute %Q{
      grant usage on schema pgjwt to postgres, microservices;
      grant select on public.configurations to microservices, postgres;
      grant execute on function public.configuration(name text) to postgres, microservices;
    }
  end
end
