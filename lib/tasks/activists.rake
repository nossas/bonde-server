namespace :activists do
  desc 'Delete activists not used'
  task free_not_used: [:environment] do
    Activist.all.order(:id).each do |activist| 
      if (Donation.where("activist_id = #{activist.id}").count == 0) && (FormEntry.where("activist_id = #{activist.id}").count == 0) && 
         (ActivistPressure.where("activist_id = #{activist.id}").count == 0) && (ActivistMatch.where("activist_id = #{activist.id}").count == 0) && 
         (CreditCard.where("activist_id = #{activist.id}").count == 0) && (Payment.where("activist_id = #{activist.id}").count == 0)
          activist.addresses.each{|addr| addr.delete}
          activist.delete
      end
    end
  end

  def find_on values, field_names
    registros = values.select{|dt| field_names.include? I18n.transliterate(dt['label'].downcase.strip)}
    return registros[0]['value'] if registros.size > 0
    nil
  end

  desc 'Correct hash data on email field'
  task hash_on_email_field: [:environment] do
    Activist.where("email like '[{%}]'").each do |activist|
      begin
        data = eval(activist.email)
        found = find_on data, ['email', 'correo electronico', 'e-mail']
        if found
          activist.email = found
          activist.save! validate: false
        else
          p data
        end
      rescue StandardError => e
        p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        p "Registro: #{activist.id}"
        p "Email: #{activist.email}"
        p activist.errors
        p e
        p '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
      end
    end
  end

  desc 'Correct hash data on name field'
  task hash_on_name_field: [:environment] do
    Activist.where("name like '[{%}]'").each do |activist|
      begin
        data = eval(activist.name)
        found = find_on data, ['nome completo', 'nombre y apellido']
        if ! found
          name = "#{((find_on data, ['nombre', 'nome*', 'nome', 'first name', 'seu nome'])||'').strip} #{find_on data, ['seu sobrenome', 'last name', 'apellido', 'sobrenome', 'sobre nome', 'sobre-nome']}".strip
          found = ( name.empty? ? nil : name )
        end
        if found
          activist.name = found
          activist.save! validate: false
        else
          p data
        end
      rescue StandardError => e
        p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        p "Registro: #{activist.id}"
        p "Nome: #{activist.name}"
        p activist
        p e
        p '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
      end
    end
  end
end

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