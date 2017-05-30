require 'rails_helper'

RSpec.describe Donation, type: :model do
  it { should belong_to :widget }
  it { should belong_to :activist }
  it { should belong_to :subscription_relation }

  it { should have_one :mobilization }
  it { should have_one :community }

  it { should belong_to :parent }
  it { should belong_to :payable_transfer }

  it { should have_many :payments }
  it { should have_many :payable_details }

  describe '#async_update_mailchimp' do
    let(:donation) { Donation.new id: 52 }

    before do 
      donation.async_update_mailchimp
    end

    it "should save data in sidekiq" do
      sidekiq_jobs = MailchimpSyncWorker.jobs
      expect(sidekiq_jobs.size).to eq(1)
      expect(sidekiq_jobs.last['args']).to eq([donation.id, 'donation'])
    end
  end

  describe 'scopes' do
    context 'paid' do
      before do
        3.times { Donation.make! transaction_status: 'paid' }
        4.times { Donation.make! transaction_status: 'pending' }
        2.times { Donation.make! transaction_status: 'refused' }
      end

      subject { Donation.paid.count }
      it { is_expected.to eq(3) }
    end
  end

  describe 'state_machine' do
    before do
      allow(donation).to receive(:notify_when_not_subscription)
    end
    let(:donation) { Donation.make! transaction_status: 'pending' }

    context "should start at pending" do
      it { expect(donation.transaction_status).to eq('pending') }
      it { expect(donation.current_state).to eq('pending') }
    end

    context "when donations has waiting_payment" do
      before do
        expect(donation).to receive(:notify_when_not_subscription).with(:waiting_payment_donation)
        donation.transition_to(:waiting_payment)
        donation.reload
      end

      it { expect(donation.transaction_status).to eq('waiting_payment') }
      it { expect(donation.current_state).to eq('waiting_payment') }
    end

    context "when donation has refused" do
      before do
        expect(donation).to receive(:notify_when_not_subscription).with(:refused_donation)
        donation.transition_to(:refused)
        donation.reload
      end

      it { expect(donation.transaction_status).to eq('refused') }
      it { expect(donation.current_state).to eq('refused') }

    end

    context "when donation has paid" do
      before do
        expect(donation).to receive(:notify_when_not_subscription).with(:paid_donation)
        donation.transition_to(:paid)
        donation.reload
      end

      it { expect(donation.transaction_status).to eq('paid') }
      it { expect(donation.current_state).to eq('paid') }
    end
  end

  describe ".notify_when_not_subscription" do
    before do
      allow(donation).to receive(:notify_activist)
    end
    let(:donation) { Donation.make! transaction_status: 'pending' }

    context "when donation has from local subcription" do
      before do
        allow(donation).to receive(:local_subscription_id).and_return(143)
        expect(donation).not_to receive(:notify_activist)
      end

      it { donation.notify_when_not_subscription :template_name }
    end

    context "when donation has not from local subscription" do
      before do
        expect(donation).to receive(:notify_activist).with(:template_name)
      end

      it { donation.notify_when_not_subscription "template_name" }
    end
  end
end
