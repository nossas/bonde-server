class AdjustGetWidgetDonationStatsToStable < ActiveRecord::Migration
  def change
    execute %Q{
alter function postgraphql.get_widget_donation_stats(widget_id integer) stable;
}
  end
end
