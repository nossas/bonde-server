require 'rails_helper'

RSpec.describe Widgets::FillController, type: :controller do
  let(:user) { User.make! }
  let(:mobilization) { Mobilization.make! user: user }
  let(:block) { Block.make! mobilization: mobilization }
  let(:widget) { Widget.make! block: block }
  let(:activist) { Activist.make! }
  let(:activist_pressure) { ActivistPressure.make! widget: widget, activist: activist }
  let(:current_user) { user }

  before do
    stub_current_user(current_user)
  end

  shared_examples "public access" do
    context "when user is mobilization owner" do
      it { is_expected.to respond_with 200 }
    end

    context "when user is not mobilization owner" do
      let(:current_user) { User.make! }
      it { is_expected.to respond_with 200 }
    end
  end

  describe "POST #create" do
    context 'widget kind ' do
      before {
        post :create, widget_id: widget, fill: { activist: { name: 'Foo Bar', email: 'foo@bar.org' } }
      }

      it_behaves_like "public access"

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return an empty object' do
        expect(response.body).to include('{}')
      end
    end

    context 'widget kind ' do
      before {
        post :create, widget_id: widget, fill: { activist: { name: 'Foo Bar', email: 'foo@bar.org', city: 'Pindamonhangaba/SP' } }
      }

      it_behaves_like "public access"

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return an empty object' do
        expect(response.body).to include('{}')
      end
    end

    context 'widget kind ' do
      before {
        widget.kind = 'pressure'
        widget.save!
        post :create, widget_id: widget, fill: {
          activist: {
            firstname: 'test201611241458',
            lastname: 'test201611241458',
            email: 'test201611241459@email.com',
            city: 'São Paulo'
          },
          mail: {
            cc: [
              'target1@email.com',
              'target2@email.com',
              'target3@email.com',
              'target4@email.com',
              'target5@email.com'
            ],
            subject: 'Assunto do email!',
            body: 'Corpo do email que será enviado.'
          }
        }
      }

      it_behaves_like "public access"

      it 'should return a 200 status' do
        expect(response.status).to be 200
      end

      it 'should return an activist_pressure object' do
        expect(response.body).to include("\"widget_id\":#{widget.id}")
        expect(response.body).to include("\"count\":")
      end
    end
  end
end

