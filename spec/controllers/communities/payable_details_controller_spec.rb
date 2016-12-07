require "rails_helper"

RSpec.describe Communities::PayableDetailsController, type: :controller do


  let(:community) { Community.make! pagarme_recipient_id: 'xxx' }
  let(:user) { User.make! }
  let(:mobilization) { Mobilization.make!(community: community, user: user) }
  let(:block) { Block.make! mobilization: mobilization }
  let(:widget) { Widget.make!(kind: 'donation', block: block) }
  let(:donation) do
    Donation.make!(
      widget: widget,
      amount: 1000,
      subscription: true,
      subscription_id: 123,
      transaction_status: 'paid',
      transaction_id: 1234,
      payables: [
        {
          id: 3992754,
          fee: 114,
          type: "credit",
          amount: 1000,
          object: "payable",
          status: "waiting_funds",
          installment: 1,
          date_created: "2016-09-05T22:29:49.060Z",
          payment_date: "2016-10-06T03:00:00.000Z",
          recipient_id: community.pagarme_recipient_id,
          split_rule_id: nil,
          payment_method: "credit_card",
          transaction_id: 123,
          anticipation_fee: 0,
          bulk_anticipation_id: nil,
          original_payment_date: nil
        }],
    )
  end

  before do
    donation
    (CommunityUser.new user: user, community: community, role: 1).save!

    stub_current_user(user)
  end

  describe 'GET #index' do
    context 'when user is not on community' do
      let(:other_user) { User.make! }

      before do
        stub_current_user(other_user)
        get :index, community_id: community.id
      end

      it "should be not authorized" do
        expect(response).to be_unauthorized
      end
    end

    context 'when user is on orgnization' do
      before do
        get :index, community_id: community.id
      end

      it "should be successful and render payable details" do
        json_details = ActiveSupport::JSON.decode(response.body)[0]

        expect(response).to be_successful
        expect(json_details["value_without_fee"]).to eq(8.86)
        expect(json_details["fee"]).to eq(1.14)
        expect(json_details["payable_value"]).to eq(10.0)
        expect(json_details["donation_value"]).to eq(10.0)
        expect(json_details["pagarme_status"]).to eq('paid')
        expect(json_details["payable_status"]).to eq('waiting_funds')
      end
    end
  end
end
