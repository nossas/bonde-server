class AddTwitterShareTextToMobilizations < ActiveRecord::Migration
  def change
    add_column :mobilizations, :twitter_share_text, :string, limit: 140
  end
end
