
require 'rails_helper'

RSpec.describe ActivistMatchesController, type: :controller do
  let(:user) { User.make! }
  let(:mobilization) { Mobilization.make! user: user }
  let(:block) { Block.make! mobilization: mobilization }
  let(:widget) { Widget.make! block: block }
  let(:match) { Match.make! widget: widget }
  let(:activist) { Activist.make! }
  let(:activist_match) { ActivistMatch.make! match: match, activist: activist }
  let(:current_user) { user }

  before do
    stub_current_user(current_user)
    match
  end

  shared_examples 'public access' do
    context 'when user is mobilization owner' do
      it { is_expected.to respond_with 200 }
    end

    context 'when user is not mobilization owner' do
      let(:current_user) { User.make! }
      it { is_expected.to respond_with 200 }
    end
  end

  describe 'POST #create' do
    context 'valid message' do
      before do
        post :create, activist_match: { match_id: match, activist: { name: 'Foo Bar', email: 'foo@bar.org' } }
      end

      it_behaves_like 'public access'

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it "should put a message on Sidekiq" do
        json_parsed = JSON.parse(response.body)
        sidekiq_jobs = MailchimpSyncWorker.jobs
        expect(sidekiq_jobs.size).to eq(1)
        expect(sidekiq_jobs.last['args']).to eq([json_parsed['id'], 'activist_match'])
      end

      it 'should return a json' do
        expect(response.body).to include('id')
        expect(response.body).to include('activist_id')
        expect(response.body).to include('match_id')
      end

      context 'correctness data' do 
        before do
          @dataJSON = JSON.parse(response.body)
          @dataDB = ActivistMatch.first
        end

        it "id should be correct" do
          expect(@dataJSON['id']).to be_eql(@dataDB.id)
        end

        it "activist_id should be correct" do
          expect(@dataJSON['activist_id']).to be_eql(@dataDB.activist_id)
        end

        it "match_id should be correct" do
          expect(@dataJSON['match_id']).to be_eql(@dataDB.match_id)
        end
      end
    end
  end
end
