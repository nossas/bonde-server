class AddTraefikRoleAndBackendToMobilizations < ActiveRecord::Migration
  def change
    add_column :mobilizations ,:traefik_host_rule, :string
    add_column :mobilizations ,:traefik_backend_address, :string
  end
end
