namespace :communities do 
  desc 'Synchronize AWS\' hosted zones'
  task synchronize_hosted_zones: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      community.synchronize_hosted_zones
    end
  end

  desc 'Synchronize AWS\' records'
  task import_records: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      community.import_aws_records
    end
  end
end
