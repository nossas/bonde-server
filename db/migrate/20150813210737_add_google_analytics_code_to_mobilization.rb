class AddGoogleAnalyticsCodeToMobilization < ActiveRecord::Migration
  def change
    add_column :mobilizations, :google_analytics_code, :string
  end
end
