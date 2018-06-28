class NotifyDomainAfterCustomDomainUpdate < ActiveRecord::Migration
  def up
    execute %Q{

create or replace function refresh_custom_domain_frontend()
returns trigger
language plpgsql
as $$
    begin
        if new.traefik_host_rule <> old.traefik_host_rule then
            perform pg_notify('dns_channel', pgjwt.sign(json_build_object(
                'action', 'refresh_frontend',
                'id', new.id,
                'created_at', now(),
                'sent_to_queuing', now(),
                'jit', now()::timestamp
            ), public.configuration('jwt_secret'), 'HS512'));
        end if;
        
        return new;
    end;
$$;

CREATE TRIGGER refresh_custom_domain_frontend
    AFTER INSERT OR UPDATE OF traefik_host_rule ON mobilizations
    FOR EACH ROW
    WHEN (new.traefik_host_rule is not null)
    EXECUTE PROCEDURE refresh_custom_domain_frontend();
}
  end

  def down
    execute %Q{
drop function refresh_custom_domain_frontend();
drop trigger refresh_custom_domain_frontend on mobilizations;
}
  end
end
