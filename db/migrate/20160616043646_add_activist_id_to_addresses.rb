class AddActivistIdToAddresses < ActiveRecord::Migration
  def change
    add_reference :addresses, :activist, index: true, foreign_key: true
    add_reference :donations, :activist, index: true, foreign_key: true
  end
end
