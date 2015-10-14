class AddSlugAndCustomDomainToMobilizations < ActiveRecord::Migration
  def change
    add_column :mobilizations, :slug, :string
    change_column_null :mobilizations, :slug, false
    add_column :mobilizations, :custom_domain, :string
  end
end
