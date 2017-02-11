namespace :activists_from do
  desc 'Create or identify activists on donations with blank activist_id'
  task donations: [:environment] do
    donations = Donation.where('activist_id is null')
    donations.each {|d| d.generate_activist }
    
    no_activists = donations.select{|d| d.activist_id == nil }
    no_activists.each do |don|
      don.activist = Activist.order(:id).find_by_email(don.email)
      don.save
    end
  end

  desc 'Create or identify activists on form_entries with blank activist_id'
  task form_entries: [:environment] do
    fes = FormEntry.where('activist_id is null')
    fes.each {|d| d.generate_activist }
  end

  desc 'Create or identify activists on form_entries and donations with blank activist_id'
  task all: ['donations:load_donation_customers', 'activists_from:donations', 'activists_from:form_entries']
end