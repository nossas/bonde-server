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
    let(:invitation) { create(:invitation, email: 'bonde@example.org') }
    let(:user) { create(:user, email: 'bonde@example.org') }
    let(:notification_template) { create(:notification_template, label: 'community_invite') }

    before do
      user
      notification_template
    end

    it 'should send an email' do
      invitation.invitation_email
      expect(Notification.count).to eq(1)
      expect(Notification.last.notification_template.label).to eq(notification_template.label)
    end
  end

  describe '#link' do
    it do
      expect(subject.link).to eq("http://localhost/invitation?code=#{subject.code}&email=#{subject.email.gsub(/@/, '%40')}")
    end
  end

  describe '#create_community_user' do
    before { subject.save }
    context 'not expired' do
      context 'with user' do
        before { create :user, email: subject.email }

        it 'shouldn\'t create an User' do
          expect{subject.create_community_user}.not_to change{User.count}
        end

        it 'should create a correct instance' do
          community_user = subject.create_community_user

          expect(community_user.community_id).to eq(subject.community_id)
          expect(community_user.role).to eq(subject.role)
        end

        it 'should turn invitation\'s expired to true' do
          subject.create_community_user
          subject.reload
          expect(subject.expired).to eq(true)
        end
      end

      context 'without user' do
        it 'should not create an User' do
          subject
          expect{subject.create_community_user}.not_to change{User.count}
        end

        it 'should not return nil' do
          community_user = subject.create_community_user

          expect(community_user).to eq(nil)
        end

        it 'should not turn invitation\'s expired to true' do
          subject.create_community_user
          subject.reload
          expect(subject.expired).to eq(false)
        end
      end
    end

    context 'expired' do
      before { create :user, email: subject.email }
      it do
        subject.expired = true
        expect(subject.create_community_user).to eq(nil)
      end

      it do
        subject.expires = (Date.today - 1)
        expect(subject.create_community_user).to eq(nil)
      end

      it 'should turn invitation\'s expired to true' do
        subject.create_community_user
        subject.reload
        expect(subject.expired).to eq(true)
      end
    end
  end
end
