require 'rails_helper'

RSpec.describe Invitation, type: :model do
  subject { build :invitation }

  it { should belong_to :community }
  it { should belong_to :user }

  it { should validate_presence_of :community_id }
  it { should validate_presence_of :user_id }
  it { should validate_presence_of :email }
  it { should validate_presence_of :role }
  it { should validate_presence_of :expires }

  describe '#save' do
    let(:invitation) { build(:invitation, code: nil, email:'anotherone@sent.ir') }

    before do
      invitation.save!
    end

    it 'should create a code' do
      expect(invitation.code).not_to eq('')
    end
  end

  describe '#invitation_email' do
    it 'should send an email' do
      expect { subject.invitation_email }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
