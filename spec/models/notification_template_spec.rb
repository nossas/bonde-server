require 'rails_helper'

RSpec.describe NotificationTemplate, type: :model do
  before do
    n = build :notification_template
  end

  it { should belong_to :community}
  it { should validate_presence_of :label }
  it { should validate_presence_of :subject_template }
  it { should validate_presence_of :body_template }

  it { should allow_value('label_valido_123').for(:label) }
  it { should allow_value('label invalido').for(:label) }

  let(:template_vars) { {name: 'name2'} }
  let(:notification) { create(:notification_template, template_vars: {name:'name1'}) }

  describe "before_save" do
    context "should downcase label before save" do
      it do
        n = create(:notification_template, label: 'Label_ToDowncase')
        expect(n.label).to eq('label_todowncase')
      end
    end
  end

  describe "generate_subject" do
    subject { notification.generate_subject(template_vars) }

    it { is_expected.to eq("hello name2") }
  end

  describe "generate_body" do
    subject { notification.generate_body(template_vars) }

    it { is_expected.to eq("World name2") }
  end
end
