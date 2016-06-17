class AddExpirationDateToCreditCards < ActiveRecord::Migration
  def change
    add_column :credit_cards, :expiration_date, :string
  end
end
