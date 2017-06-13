require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { should belong_to :activist}
  it { should belong_to :user}
  it { should belong_to :notification_template}

  it { should validate_presence_of :notification_template }

  let(:notification_template) { create(:notification_template) }

  let(:activist) { create(:activist) }
  let(:user) { create(:user) }
  let(:community) { create(:community, email_template_from: 'custom@email.com')}


  describe ".notify!" do
    context "notification from community" do

      context "to an activist through it's activist id" do
        subject { Notification.notify!(activist.id, notification_template.label, { name: 'lorem1'}, community.id) }
        before do
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label, community_id: community.id).and_call_original
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label).and_call_original
        end

        it do
          expect(subject.activist).to eq(activist)
          expect(subject.user).not_to be
          expect(subject.email).not_to be
          expect(subject.community).to eq(community)
          expect(subject.notification_template).to eq(notification_template)
          expect(subject.template_vars).to_not be_nil
          expect(subject.persisted?).to eq(true)
        end
      end

      context "to an activist" do
        subject { Notification.notify!(activist, notification_template.label, { name: 'lorem1'}, community.id) }
        before do
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label, community_id: community.id).and_call_original
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label).and_call_original
        end

        it do
          expect(subject.activist).to eq(activist)
          expect(subject.user).not_to be
          expect(subject.email).not_to be
          expect(subject.community).to eq(community)
          expect(subject.notification_template).to eq(notification_template)
          expect(subject.template_vars).to_not be_nil
          expect(subject.persisted?).to eq(true)
        end
      end

      context "to an user" do
        subject { Notification.notify!(user, notification_template.label, { name: 'lorem1'}, community.id) }
        before do
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label, community_id: community.id).and_call_original
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label).and_call_original
        end

        it do
          expect(subject.activist).not_to be
          expect(subject.user).to eq(user)
          expect(subject.email).not_to be
          expect(subject.community).to eq(community)
          expect(subject.notification_template).to eq(notification_template)
          expect(subject.template_vars).to_not be_nil
          expect(subject.persisted?).to eq(true)
        end
      end


      context "to an email" do
        subject { Notification.notify!("ask@me.com", notification_template.label, { name: 'lorem1'}, community.id) }

        before do
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label, community_id: community.id).and_call_original
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label).and_call_original
        end

        it do
          expect(subject.activist).not_to be
          expect(subject.email).to eq('ask@me.com')
          expect(subject.user).not_to be
          expect(subject.notification_template).to eq(notification_template)
          expect(subject.template_vars).to_not be_nil
          expect(subject.persisted?).to eq(true)
        end
      end

    end


    context "notification without community" do
      context "to an activist through it's activist id" do
        subject { Notification.notify!(activist.id, notification_template.label, { name: 'lorem1'}) }
        before do
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label, community_id: nil).and_call_original
        end

        it do
          expect(subject.activist).to eq(activist)
          expect(subject.email).not_to be
          expect(subject.user).not_to be
          expect(subject.notification_template).to eq(notification_template)
          expect(subject.template_vars).to_not be_nil
          expect(subject.persisted?).to eq(true)
        end
      end

      context "to an activist" do
        subject { Notification.notify!(activist, notification_template.label, { name: 'lorem1'}) }
        before do
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label, community_id: nil).and_call_original
        end

        it do
          expect(subject.activist).to eq(activist)
          expect(subject.email).not_to be
          expect(subject.user).not_to be
          expect(subject.notification_template).to eq(notification_template)
          expect(subject.template_vars).to_not be_nil
          expect(subject.persisted?).to eq(true)
        end
      end

      context "to an user" do
        subject { Notification.notify!(user, notification_template.label, { name: 'lorem1'}) }

        before do
          allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label, community_id: nil).and_call_original
        end

        it do
          expect(subject.activist).not_to be
          expect(subject.email).not_to be
          expect(subject.user).to eq(user)
          expect(subject.notification_template).to eq(notification_template)
          expect(subject.template_vars).to_not be_nil
          expect(subject.persisted?).to eq(true)
        end
      end
    end

    context "to an email" do
      subject { Notification.notify!("ask@me.com", notification_template.label, { name: 'lorem1'}) }

      before do
        allow(NotificationTemplate).to receive(:find_by).with(label: notification_template.label, community_id: nil).and_call_original
      end

      it do
        expect(subject.activist).not_to be
        expect(subject.email).to eq('ask@me.com')
        expect(subject.user).not_to be
        expect(subject.notification_template).to eq(notification_template)
        expect(subject.template_vars).to_not be_nil
        expect(subject.persisted?).to eq(true)
      end
    end
  end

  describe "#deliver_without_queue" do
    subject { Notification.notify!(activist.id, notification_template.label, { name: 'lorem1'}) }
  
    let(:delivered) { subject.deliver_without_queue }

    it do
      expect{ delivered }.to change{ActionMailer::Base.deliveries.count}.by(1)
    end

    it do
      deliveries = ActionMailer::Base.deliveries
      delivered
      expect(deliveries.last).to eq(delivered)
    end
  end
end
