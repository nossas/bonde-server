namespace :communities do 
  desc 'Import AWS\' hosted zones'
  task import_hosted_zones: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      erros += community.import_hosted_zones
    end
    erros
  end

  desc 'Export AWS\' hosted zones'
  task export_hosted_zones: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      erros += community.export_hosted_zones
    end
    erros
  end

  desc 'Synchronize AWS\' records'
  task import_records: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      erros += community.import_aws_records
    end
    erros
  end

  desc 'Export AWS\' records'
  task import_records: [:environment] do
    erros = [ ]

    Community.all.each do |community|
      erros += community.export_aws_records
    end
    erros
  end
end
