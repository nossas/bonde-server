require 'rails_helper'

RSpec.describe Recipient, type: :model do
  it { should belong_to :community }
  
  it { should validate_presence_of :pagarme_recipient_id }
  it { should validate_presence_of :recipient }
  it { should validate_presence_of :community }


  describe '#update_from_pagarme' do
    context 'empty recipient' do
      it "raise an error if pagarme_recipient_id is empty" do
        recipient = Recipient.new

        expect { recipient.update_from_pagarme }.to raise_error(PagarMe::PagarMeError)
      end
    end

    context 'recipient with data' do
      let(:recipient) { Recipient.make! }
      let(:payload) { {
          object: "recipient",
          id: "re_ci9bucss300h1zt6dvywufeqc",
          bank_account: {
            object: "bank_account",
            id: 4841,
            bank_code: "341",
            agencia: "0932",
            agencia_dv: "5",
            conta: "58054",
            conta_dv: "1",
            document_type: "cpf",
            document_number: "26268738888",
            legal_name: "API BANK ACCOUNT",
            charge_transfer_fees: false,
            date_created: "2015-03-19T15:40:51.000Z"
          },
          transfer_enabled: false,
          last_transfer: nil,
          transfer_interval: "weekly",
          transfer_day: 15,
          automatic_anticipation_enabled: true,
          anticipatable_volume_percentage: 85,
          date_created: "2015-05-05T21:41:48.000Z",
          date_updated: "2015-05-05T21:41:48.000Z"
      } }

      before do
        stub_request(:get, "https://api.pagar.me/1/recipients/re_ci9bucss300h1zt6dvywufeqc").
          to_return(:status => 200, :body => payload.to_json, :headers => {} )
        PagarMe.api_key = 'FalseApiKey4Testing'
        recipient.update_from_pagarme
      end

      it 'should save from pagarme' do
        register = Recipient.find recipient.id

        payload.each do |k,v|
          if k.to_s == 'bank_account'
            p_bank = payload[k]
            r_bank = register.recipient['bank_account']
            p_bank.each { |b_k, b_v| expect(r_bank[b_k.to_s]).to eq b_v  }
          else
            expect(register.recipient[k.to_s]).to eq(v)
          end
          expect(register.recipient['bank_account'].keys.count).to be payload[:bank_account].keys.count
        end
        expect(register.recipient.keys.count).to be payload.keys.count
      end
    end
  end
end
