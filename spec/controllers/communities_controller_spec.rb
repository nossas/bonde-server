require 'rails_helper'

RSpec.describe CommunitiesController, type: :controller do
  before do 
    @user = User.make!

    stub_current_user(@user)
  end

  describe "GET #index" do
    it "should return all communities" do
      communities = []
      3.times { Community.make! }
      2.times { communities << Community.make! }
      communities.each do  |community|
        CommunityUser.create user: @user, community: community, role: 1
      end
      get :index

      communities.each do |c|
        expect(response.body).to include(c.name)
      end
      expect(response.body).to include('account_dig')
      expect(response.body).to include('agency_dig')
      expect(JSON.parse(response.body).count).to be 2
    end
  end

  describe 'POST #create' do
    context 'valid call' do
      let(:vals) {{
            name: 'José Marculino Silva',
            city: 'Pindamonhangaba, SP',
            description: 'A community to solve ours problems',
            mailchimp_api_key: 'abc56',
            mailchimp_list_id: '1234',
            mailchimp_group_id: '7890'
          }}
      before do
        @count = Community.count
        post :create, {
          format: :json, 
          community: vals
        }
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should have one more register on disk' do
        expect(Community.count).to be(@count + 1)
      end

      it 'should return the data saved' do
        vals.each do |f, v|
          expect(response.body).to include(f.to_s)
          expect(response.body).to include(v)
        end
      end

      it 'should correctly save the data' do
        dt = JSON.parse response.body
        saved = Community.find dt['id']

        expect(saved.mailchimp_api_key).to eq('abc56')
        expect(saved.mailchimp_list_id).to eq('1234')
        expect(saved.mailchimp_group_id).to eq('7890')
        expect(saved.description).to eq('A community to solve ours problems')
        expect(saved.city).to eq('Pindamonhangaba, SP')
        expect(saved.name).to eq('José Marculino Silva')
      end
    end

    context 'user not logged' do 
      before do
        stub_current_user(nil)
        @count = Community.count
        post :create, {
          format: :json, 
          community: {
            name: 'José Joselito',
            city: 'Taubaté, SP'
          }
        }
      end

      it 'should return a 401 status' do
        expect(response.status).to be 401
      end
    end


    context 'Fields missing' do 
      before do
        post :create, {
          format: :json, 
          community: {
            cidate: 'Taubaté, SP'
          }
        }
      end

      it 'should return a 400 status' do
        expect(response.status).to be 400
      end

      it 'should return error messaage' do
        expect(response.body).to be
      end
    end
  end





  describe 'PUT #update' do
    let!(:community) { Community.make! }

    context 'should return 404 if community not exists' do
      before {
        put :update, {
          format: :json, 
          id: 0,
          community: {
            city: 'Tremembé, SP'
          }
        }
      }

      it { should respond_with 404 }
    end
    
    context 'user not logged' do 
      before do
        stub_current_user(nil)

        put :update, {
          format: :json, 
          id: community.id,
          community: {
            name: 'José Joselito',
            city: 'Taubaté, SP'
          }
        }
      end

      it { should respond_with 401 }
    end

    context 'only data' do
      context 'on happy path' do
        before do
          (CommunityUser.new user: @user, community: community, role: 1).save!

          @count = Community.count
          put :update, {
            format: :json, 
            id: community.id,
            community: {
              city: 'Tremembé, SP',
              image: 'http://images.reboo.org/our_fight.png',
              description: 'The strongest community',
              mailchimp_api_key: 'ab12cd',
              mailchimp_list_id: '34ef56',
              mailchimp_group_id: '78gh90'
            }
          }
        end

        it { should respond_with 200 }

        it 'should return the data saved' do
          expect(response.body).to include('recipient')
          expect(response.body).to include('transfer_interval')
          expect(response.body).to include('transfer_day')
          expect(response.body).to include('transfer_enabled')
          expect(response.body).to include('bank_account')
          expect(response.body).to include('legal_name')
          expect(response.body).to include('document_number')
          expect(response.body).to include('name')
          expect(response.body).to include('city')
        end

        it 'should change the data' do
          saved = Community.find community.id

          expect(saved.city).to eq 'Tremembé, SP'
          expect(saved.image).to eq 'http://images.reboo.org/our_fight.png'
        end


        it 'should correctly save the data' do
          saved = Community.find community.id

          expect(saved.mailchimp_api_key).to eq('ab12cd')
          expect(saved.mailchimp_list_id).to eq('34ef56')
          expect(saved.mailchimp_group_id).to eq('78gh90')
          expect(saved.description).to eq('The strongest community')
          expect(saved.city).to eq('Tremembé, SP')
          expect(saved.image).to eq('http://images.reboo.org/our_fight.png')
        end
      end
    end


    context 'recipient' do 
      let(:recipient_response) {{
        object: "recipient",
        id: "re_ci9bucss300h1zt6dvywufeqc",
        bank_account: {
          object: "bank_account",
          id: 4851,
          bank_code: "237",
          agencia: "1935",
          agencia_dv: "9",
          conta: "23398",
          conta_dv: "9",
          document_type: "cpf",
          document_number: "26268738888",
          legal_name: "API BANK ACCOUNT",
          charge_transfer_fees: false,
          date_created: "2015-03-19T15:40:51.000Z"
        },
        transfer_enabled: true,
        last_transfer: nil,
        transfer_interval: "monthly",
        transfer_day: 15,
        automatic_anticipation_enabled: true,
        anticipatable_volume_percentage: 85,
        date_created: "2015-05-05T21:41:48.000Z",
        date_updated: "2015-05-05T21:41:48.000Z"
      }}

      let(:recipient_return) {{
        object: "recipient",
        id: "re_ci9bucss300h1zt6dvywufeqc",
        bank_account: {
          object: "bank_account",
          id: 4851,
          bank_code: "237",
          agency: "1935",
          agency_dig: "9",
          account: "23398",
          account_dig: "9",
          document_type: "cpf",
          document_number: "26268738888",
          legal_name: "API BANK ACCOUNT",
          charge_transfer_fees: false,
          date_created: "2015-03-19T15:40:51.000Z"
        },
        transfer_enabled: true,
        last_transfer: nil,
        transfer_interval: "monthly",
        transfer_day: 15,
        automatic_anticipation_enabled: true,
        anticipatable_volume_percentage: 85,
        date_created: "2015-05-05T21:41:48.000Z",
        date_updated: "2015-05-05T21:41:48.000Z"
      }}

      let(:recipient_request) {
        {
          transfer_interval: "monthly",
          transfer_day: 15,
          transfer_enabled: true,
          bank_account: {
            bank_code: '237',
            agency: '1935',
            agency_dig: '9',
            account: '23398',
            account_dig: '9',
            type: 'conta_corrente',
            legal_name: 'API BANK ACCOUNT',
            document_number: '26268738888'
          }
        }
      }

      before do
        PagarMe.api_key = 'MyFakeKey'
        CommunityUser.create! user: @user, community: community, role: 1
      end

      # BANK CODE

      context 'bank_code less than 3 digits' do
        before do
          recipient_request[:bank_account][:bank_code] = '12'

          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Código bancário inválido')
        end
      end

      context 'bank_code more than 3 digits' do
        before do
          recipient_request[:bank_account][:bank_code] = '1212'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Código bancário inválido')
        end
      end

      context 'bank_code with alfa values' do
        before do
          recipient_request[:bank_account][:bank_code] = '2A2'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Código bancário inválido')
        end
      end

      # Agencia

      context 'agencia more than 5 digits' do
        before do
          recipient_request[:bank_account][:agencia] = '121212'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Código de agência inválido')
        end
      end

      context 'agencia with alfa values' do
        before do
          recipient_request[:bank_account][:agencia] = '1A212'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Código de agência inválido')
        end
      end

      # Agencia DV

      context 'agencia_dv less than 1 digit' do
        before do
          recipient_request[:bank_account][:agencia_dv] = ''
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Dígito verificador da agência inválido')
        end
      end


      context 'agencia_dv more than 1 digit' do
        before do
          recipient_request[:bank_account][:agencia_dv] = '121212'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Dígito verificador da agência inválido')
        end
      end

      context 'agencia_dv with alfa value' do
        before do
          recipient_request[:bank_account][:agencia_dv] = 'B'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Dígito verificador da agência inválido')
        end
      end

      # CONTA

      context 'conta more than 13 digit' do
        before do
          recipient_request[:bank_account][:conta] = '12345678901234'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Número da conta bancária inválida')
        end
      end

      context 'conta with alfa values' do
        before do
          recipient_request[:bank_account][:conta] = 'a123B'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Número da conta bancária inválida')
        end
      end

      # CONTA_DV

      context 'conta_dv more than 2 alfanumeric' do
        before do
          recipient_request[:bank_account][:conta_dv] = '12S'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Dígito verificador da conta bancária inválido')
        end
      end

      # Bank Account type

      context 'conta_dv more than 2 alfanumeric' do
        before do
          recipient_request[:bank_account][:type] = 'conta conjunta'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Tipo de conta inválido')
        end
      end 

      # document_number

      context 'document_number less than 11 alfanumeric' do
        before do
          recipient_request[:bank_account][:document_number] = '1234567890'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Número de documento inválido')
        end
      end 

      context 'document_number more than 11 and less than 14 alfanumeric' do
        before do
          recipient_request[:bank_account][:document_number] = '123456789012'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Número de documento inválido')
        end
      end 

      context 'document_number more than 14 alfanumeric' do
        before do
          recipient_request[:bank_account][:document_number] = '123456789012345'
          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it {should respond_with 400}

        it 'should return error message' do
          expect(response.body).to include('Número de documento inválido')
        end
      end 

      context 'create recipient' do
        before do 
          community.update_attributes recipient: nil, pagarme_recipient_id: nil
          stub_request(:post, "https://api.pagar.me/1/recipients").
            with(:body => "{\"transfer_interval\":\"monthly\",\"transfer_day\":15,\"transfer_enabled\":true,\"bank_account\":{\"bank_code\":\"237\",\"agencia\":\"1935\",\"agencia_dv\":\"9\",\"conta\":\"23398\",\"conta_dv\":\"9\",\"type\":\"conta_corrente\",\"legal_name\":\"API BANK ACCOUNT\",\"document_number\":\"26268738888\"}}").
            to_return(:status => 200, :body => recipient_response.to_json, :headers => {})

          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it { should respond_with 200 }

        context 'data' do
          let(:saved) {Community.find community.id}

          it 'should save recipient data' do
            expect(saved.recipient).to eq(JSON.parse(recipient_response.to_json))
          end

          it 'should update pagarme_recipient_id' do
            expect(saved.pagarme_recipient_id).to eq('re_ci9bucss300h1zt6dvywufeqc')
          end
          it 'should update transfer_day' do
            expect(saved.transfer_day).to be 15
          end
          it 'should update transfer_enabled' do
            expect(saved.transfer_enabled).to eq(true)
          end
        end
      end

      context 'update recipient' do
        before do 
          stub_request(:put, "https://api.pagar.me/1/recipients/re_ci9bucss300h1zt6dvywufeqc").
            with(:body => "{\"transfer_interval\":\"monthly\",\"transfer_day\":15,\"transfer_enabled\":true,\"bank_account\":{\"bank_code\":\"237\",\"agencia\":\"1935\",\"agencia_dv\":\"9\",\"conta\":\"23398\",\"conta_dv\":\"9\",\"type\":\"conta_corrente\",\"legal_name\":\"API BANK ACCOUNT\",\"document_number\":\"26268738888\"}}").
            to_return(:status => 200, :body => recipient_response.to_json, :headers => {})

          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it { should respond_with 200 }

        context 'data' do
          let(:saved) {Community.find community.id}

          it 'should save recipient data' do
            expect(saved.recipient).to eq(JSON.parse(recipient_response.to_json))
          end

          it 'should update pagarme_recipient_id' do
            expect(saved.pagarme_recipient_id).to eq('re_ci9bucss300h1zt6dvywufeqc')
          end
          it 'should update transfer_day' do
            expect(saved.transfer_day).to be 15
          end
          it 'should update transfer_enabled' do
            expect(saved.transfer_enabled).to eq(true)
          end
        end
      end

      context 'update recipient' do
        before do 
          stub_request(:put, "https://api.pagar.me/1/recipients/re_ci9bucss300h1zt6dvywufeqc").
            with(:body => "{\"transfer_interval\":\"monthly\",\"transfer_day\":15,\"transfer_enabled\":true,\"bank_account\":{\"bank_code\":\"237\",\"agencia\":\"1935\",\"agencia_dv\":\"9\",\"conta\":\"23398\",\"conta_dv\":\"9\",\"type\":\"conta_corrente\",\"legal_name\":\"API BANK ACCOUNT\",\"document_number\":\"26268738888\"}}").
            to_return(:status => 503, :body => 'Service unavailable', :headers => {})

          put :update, {
            format: :json, 
            id: community.id,
            community: { recipient: recipient_request }
          }
        end

        it { should respond_with :internal_server_error }

        context 'error message' do
          it 'should update transfer_enabled' do
            expect(response.body).to include("Serviço temporariamente indisponível")
          end
        end
      end
    end
  end



  describe 'GET #show' do
    let(:community) { Community.make! }

    context 'user with rights' do
      before do
        CommunityUser.create user: @user, community: community, role: 1
    
        get :show, {id: community.id}
      end

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return the expected data' do
        expect(response.body).to include(community.name)
        expect(response.body).to include("#{community.id}")
        expect(response.body).to include("agency")
        expect(response.body).to include("account")
      end
    end

    context 'user with rights' do
      it 'should return a 401 status' do
        stub_current_user(User.make!)
        CommunityUser.create user: @user, community: community, role: 1
        get :show, {id: community.id}

        expect(response.status).to be 401
      end
    end

    context 'user with rights' do
      it 'should return a 404 status' do
        get :show, {id: 0}

        expect(response.status).to be 404
      end
    end
  end


  describe 'GET #list_mobilizations' do
    let(:community) {Community.make!}
    let(:user2) {User.make!}


    before do
      CommunityUser.create! user: @user, community: community, role: 3

      @mob1 = Mobilization.make! user: @user, custom_domain: "foobar", slug: "1.1-foo", community: community
      @mob2 = Mobilization.make! user: user2, community: community
      @mob3 = Mobilization.make! user: @user, custom_domain: "foobar2", slug: "1.2-foo", community: community
      @mob4 = Mobilization.make! user: @user, custom_domain: "foobar", slug: "2-foo"
      @mob5 = Mobilization.make! user: user2
    end

    context "inexistent community" do
      before do
        get :list_mobilizations, {community_id: 0}    
      end

      it 'should return a 404 status' do
        expect(response.status).to be 404
      end
    end

    context "valid call" do
      context 'no filters' do
        before do
          get :list_mobilizations, {community_id: community.id}
        end

        it 'should return a 200 status' do
          expect(response.status).to be 200
        end

        it "should return all mobilizations related to the community" do
          expect(response.body).to include(@mob1.name)
          expect(response.body).to include(@mob2.name)
          expect(response.body).to include(@mob3.name)
          expect(response.body).not_to include(@mob4.name)
          expect(response.body).not_to include(@mob5.name)
        end
      end

      context 'mobilizations by custom_domain' do
        before do
          get :list_mobilizations, {custom_domain: "foobar", community_id: community.id}
        end

        it 'should return a 200 status' do
          expect(response.status).to be 200
        end

        it "should return all mobilizations related to the community" do
          expect(response.body).to include(@mob1.name)
          expect(response.body).not_to include(@mob2.name)
          expect(response.body).not_to include(@mob3.name)
          expect(response.body).not_to include(@mob4.name)
          expect(response.body).not_to include(@mob5.name)
        end
      end

      context 'mobilizations by slug' do
        before do
          get :list_mobilizations, {slug: "1.1-foo", community_id: community.id}
        end

        it 'should return a 200 status' do
          expect(response.status).to be 200
        end

        it "should return all mobilizations related to the community" do
          expect(response.body).to include(@mob1.name)
          expect(response.body).not_to include(@mob2.name)
          expect(response.body).not_to include(@mob3.name)
          expect(response.body).not_to include(@mob4.name)
          expect(response.body).not_to include(@mob5.name)
        end
      end

      context 'mobilizations by id' do
        before do
          get :list_mobilizations, {ids: [@mob3.id], community_id: community.id}
        end

        it 'should return a 200 status' do
          expect(response.status).to be 200
        end

        it "should return all mobilizations related to the community" do
          expect(response.body).to include(@mob3.name)
          expect(response.body).not_to include(@mob1.name)
          expect(response.body).not_to include(@mob2.name)
          expect(response.body).not_to include(@mob4.name)
          expect(response.body).not_to include(@mob5.name)
        end
      end
    end
  end
end
