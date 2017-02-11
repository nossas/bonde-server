namespace :donations do 
  desc 'Load customer from donation records with have customer empty'
  task load_customers_from_pagarme: [:environment] do
    erros = [ ]
    Donation.where('customer is null').order(:id).each do |donation| 
      begin
        donation.reload_transaction_data 
        donation.save!
      rescue PagarMe::NotFound => e 
        erros << donation
      end
    end
    erros.each {|d| p "Id: #{d.id}"} if erros.size > 0  
  end
end