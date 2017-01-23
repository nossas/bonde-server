module PagarmeHelper
  def to_pagarme_recipient recipient_data
    output = recipient_data.clone

    if recipient_data['bank_account']
      output.delete 'bank_account'
      output['bank_account'] = to_pagarme_bank_account(recipient_data['bank_account']) 
    end

    output
  end

  def from_pagarme_recipient recipient_data
    output = recipient_data.clone

    if recipient_data['bank_account']
      output.delete 'bank_account'
      output['bank_account'] = from_pagarme_bank_account(recipient_data['bank_account']) 
    end

    output
  end

  private 

  def to_pagarme_bank_account conta
    field_names = {
      'bank_code' => 'bank_code',
      'agency' => 'agencia',
      'agencia' => 'agencia',
      'agency_dig' => 'agencia_dv',
      'agencia_dv' => 'agencia_dv',
      'account' => 'conta',
      'conta' => 'conta',
      'account_dig' => 'conta_dv',
      'conta_dv' => 'conta_dv',
      'type' => 'type',
      'legal_name' => 'legal_name',
      'document_number' => 'document_number'
    }
    return_values = {}

    conta.each { |field_name, value| return_values[field_names[field_name]] = value }

    return_values
  end

  def from_pagarme_bank_account conta
    field_names = {
       'agencia' => 'agency',
       'agencia_dv' => 'agency_dig',
       'conta' => 'account',
       'conta_dv' => 'account_dig'
    }
    return_values = {}

    conta.each { |field_name, value| return_values[field_names[field_name]||field_name] = value }

    return_values
  end
end