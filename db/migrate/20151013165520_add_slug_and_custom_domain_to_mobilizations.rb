class AddSlugAndCustomDomainToMobilizations < ActiveRecord::Migration
  def change
    add_column :mobilizations, :slug, :string
    add_column :mobilizations, :custom_domain, :string
  end
end
