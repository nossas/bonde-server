class AddPagarmeRecipientIdToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :pagarme_recipient_id, :string
  end
end
