class AddMissingPermissionsToPostgres < ActiveRecord::Migration
  def change
    execute %Q{
      grant usage on schema pgjwt to microservices;
      grant select on public.configurations to microservices;
      grant execute on function public.configuration(name text) to microservices;
    }
  end
end
