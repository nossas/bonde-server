namespace :communities do 
  desc 'Import AWS\' hosted zones'
  task import_hosted_zones: [:environment] do
    erros = [ ]

    Communities.all.each do |community|
      community.synchronize_hosted_zones
    end
  end
end