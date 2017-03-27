require 'rails_helper'

RSpec.describe Invitation, type: :model do
  subject { build :invitation, expires: (Date.today + 1) }

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

  describe '#link' do
    it do
      expect(subject.link).to eq("http://localhost/invitation?code=#{subject.code}&email=#{subject.email.gsub(/@/, '%40')}")
    end
  end

  describe '#create_community_user' do
    context 'not expired' do
      it 'should create a correct instance' do
        community_user = subject.create_community_user

        expect(community_user.user_id).to eq(subject.user_id)
        expect(community_user.community_id).to eq(subject.community_id)
        expect(community_user.role).to eq(subject.role)
      end
    end

    context 'expired' do
      it do
        subject.expired = true
        expect{subject.create_community_user}.to raise_error(InvitationException)
      end

      it do
        subject.expires = (Date.today - 1)
        expect{subject.create_community_user}.to raise_error(InvitationException)
      end
    end
  end
end
