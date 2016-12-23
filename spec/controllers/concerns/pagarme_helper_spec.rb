require 'rails_helper'

class Fake
  include PagarmeHelper
end

def version_to_outuput
  {
    :short => {
      :internal => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account_id' => 31
      },
      :external => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account_id' => 31
      }        
    },
    :long => {
      :internal => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account' => {
          'bank_code' => '237',
          'agencia' => '1935',
          'agencia_dv' => '9',
          'conta' => '23398',
          'conta_dv' => '9',
          'type' => 'conta_corrente',
          'legal_name' => 'foo bar loem',
          'document_number' => '111.111.111-11'
        }
      },
      :external => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account' => {
          'bank_code' => '237',
          'agency' => '1935',
          'agency_dig' => '9',
          'account' => '23398',
          'account_dig' => '9',
          'type' => 'conta_corrente',
          'legal_name' => 'foo bar loem',
          'document_number' => '111.111.111-11'
        }
      }
    }
  }
end

def tests_versions_to
  {
    :short => {
      :original => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account_id' => 31
      },
      :other => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account_id' => 31
      }        
    },
    :long => {
      :original => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account' => {
          'bank_code' => '237',
          'agencia' => '1935',
          'agencia_dv' => '9',
          'conta' => '23398',
          'conta_dv' => '9',
          'type' => 'conta_corrente',
          'legal_name' => 'foo bar loem',
          'document_number' => '111.111.111-11'
        }
      },
      :other => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account' => {
          'bank_code' => '237',
          'agency' => '1935',
          'agency_dig' => '9',
          'account' => '23398',
          'account_dig' => '9',
          'type' => 'conta_corrente',
          'legal_name' => 'foo bar loem',
          'document_number' => '111.111.111-11'
        }
      }
    },        
    :long_original => {
      :original => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account' => {
          'bank_code' => '237',
          'agencia' => '1935',
          'agencia_dv' => '9',
          'conta' => '23398',
          'conta_dv' => '9',
          'type' => 'conta_corrente',
          'legal_name' => 'foo bar loem',
          'document_number' => '111.111.111-11'
        }
      },
      :other => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account' => {
          'bank_code' => '237',
          'agencia' => '1935',
          'agencia_dv' => '9',
          'conta' => '23398',
          'conta_dv' => '9',
          'type' => 'conta_corrente',
          'legal_name' => 'foo bar loem',
          'document_number' => '111.111.111-11'
        }
      }
    },        
    :long_mixed => {
      :original => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account' => {
          'bank_code' => '237',
          'agencia' => '1935',
          'agencia_dv' => '9',
          'conta' => '23398',
          'conta_dv' => '9',
          'type' => 'conta_corrente',
          'legal_name' => 'foo bar loem',
          'document_number' => '111.111.111-11'
        }
      },
      :other => {
        'transfer_interval' => "weekly",
        'transfer_day' => 5,
        'transfer_enabled' => true,
        'bank_account' => {
          'bank_code' => '237',
          'agency' => '1935',
          'agencia_dv' => '9',
          'account' => '23398',
          'conta_dv' => '9',
          'type' => 'conta_corrente',
          'legal_name' => 'foo bar loem',
          'document_number' => '111.111.111-11'
        }
      }        
    }
  }
end

RSpec.describe PagarmeHelper do
  let(:pagarme_helper) { Fake.new }

  describe '#to_pagarme_recipient' do
    tests_versions_to.each do |version_name, version|
      it "should exchange #{version_name} correctly" do
        comparacao = pagarme_helper.to_pagarme_recipient version[:other]

        expect(comparacao).to eq(version[:original])
      end
    end
  end

  describe '#from_pagarme_recipient' do
    version_to_outuput.each do |version_name, version|
      it "should exchange #{version_name} correctly" do
        comparacao = pagarme_helper.from_pagarme_recipient version[:internal]

        expect(comparacao).to eq(version[:external])
      end
    end
  end
end
''