class AddUniqueCustomDomainToMobilization < ActiveRecord::Migration
  def up
    Mobilization.where("custom_domain = ''").
      update_all custom_domain: nil

    add_index :mobilizations, :custom_domain, unique:true
  end

  def down
    remove_index :mobilizations, :custom_domain
  end
end
