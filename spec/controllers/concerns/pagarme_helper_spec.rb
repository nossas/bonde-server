require 'rails_helper'

class Fake
  include PagarmeHelper
end

def short_payload id1, id2
  {
    id1 => {
      'transfer_interval' => "weekly",
      'transfer_day' => 5,
      'transfer_enabled' => true,
      'bank_account_id' => 31
    },
    id2 => {
      'transfer_interval' => "weekly",
      'transfer_day' => 5,
      'transfer_enabled' => true,
      'bank_account_id' => 31
    }        
  }
end

def long_payload id1, id2
  { id1 => {
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
    id2 => {
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
    } }
end

def long_payload_remove_data id1, id2
  { id1 => {
      'transfer_interval' => "weekly",
      'transfer_day' => 5,
      'transfer_enabled' => true,
      'bank_account' => {
        'bank_code' => '237',
        'agencia' => '1935',
        'conta' => '23398',
        'conta_dv' => '9',
        'type' => 'conta_corrente',
        'legal_name' => 'foo bar loem',
        'document_number' => '111.111.111-11'
      }
    },
    id2 => {
      'transfer_interval' => "weekly",
      'transfer_day' => 5,
      'transfer_enabled' => true,
      'bank_account' => {
        'bank_code' => '237',
        'agency' => '1935',
        'agency_dig' => '',
        'account' => '23398',
        'account_dig' => '9',
        'type' => 'conta_corrente',
        'legal_name' => 'foo bar loem',
        'document_number' => '111.111.111-11'
      }
    } }
end

def long_payload_no_agency_dig id1, id2
  { id1 => {
      'transfer_interval' => "weekly",
      'transfer_day' => 5,
      'transfer_enabled' => true,
      'bank_account' => {
        'bank_code' => '237',
        'agencia' => '1935',
        'conta' => '23398',
        'conta_dv' => '9',
        'type' => 'conta_corrente',
        'legal_name' => 'foo bar loem',
        'document_number' => '111.111.111-11'
      }
    },
    id2 => {
      'transfer_interval' => "weekly",
      'transfer_day' => 5,
      'transfer_enabled' => true,
      'bank_account' => {
        'bank_code' => '237',
        'agency' => '1935',
        'account' => '23398',
        'account_dig' => '9',
        'type' => 'conta_corrente',
        'legal_name' => 'foo bar loem',
        'document_number' => '111.111.111-11'
      }
    } }
end

def long_payload_mixed
  { :original => {
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
    } }
end

def version_to_outuput
  {
    :short => short_payload(:internal, :external),
    :long => short_payload(:internal, :external)
  }
end

def tests_versions_to
  {
    :short => short_payload(:original, :other),
    :long => long_payload(:original, :other),
    :long_no_agency_dig => long_payload_no_agency_dig(:original, :other),
    :long_payload_remove_data => long_payload_remove_data(:original, :other),
    :long_mixed => long_payload_mixed
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
