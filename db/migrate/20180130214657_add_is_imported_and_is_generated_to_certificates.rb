class AddIsImportedAndIsGeneratedToCertificates < ActiveRecord::Migration
    def up
        add_column :certificates, :is_imported, :boolean
        add_column :certificates, :is_generated, :boolean

        execute <<-SQL
            grant insert on microservices.certificates to microservices;
            grant usage on sequence public.certificates_id_seq to microservices;
        SQL
    end
    def down
        remove_column :certificates, :is_imported
        remove_column :certificates, :is_generated

        execute <<-SQL
            revoke insert on microservices.certificates from microservices;
            revoke usage on sequence public.certificates_id_seq from microservices;
        SQL
      end
  end