require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { should belong_to :activist}
  it { should belong_to :notification_template}
  it { should validate_presence_of :activist}
  it { should validate_presence_of :notification_template }

  describe ".notify!" do
    let(:activist) { create(:activist) }
    let(:notification_template) { create(:notification_template) }

    subject { Notification.notify!(activist.id, notification_template.label, { name: 'lorem1'}) }

    context "should create an notification for activist" do
      before do
        allow(NotificationTemplate).to receive(:find_by_label).with(notification_template.label).and_call_original
      end

      it do
        expect(subject.activist).to eq(activist)
        expect(subject.notification_template).to eq(notification_template)
        expect(subject.template_vars).to_not be_nil
        expect(subject.persisted?).to eq(true)
      end
    end
  end
end
