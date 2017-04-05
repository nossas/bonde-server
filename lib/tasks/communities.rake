namespace :communities do 
  desc 'Import AWS\' hosted zones'
  task import_hosted_zones: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      community.import_hosted_zones
    end
  end

  desc 'Export AWS\' hosted zones'
  task export_hosted_zones: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      community.export_hosted_zones
    end
  end

  desc 'Synchronize AWS\' records'
  task import_records: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      community.import_aws_records
    end
  end

  desc 'Export AWS\' records'
  task import_records: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      community.export_aws_records
    end
  end
end
