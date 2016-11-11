require 'rails_helper'

RSpec.describe UploadPolicy do
  context "for a visitor" do
    subject { described_class.new(nil, nil) }
    it { should allows(:index) }
  end

  context "for a non-owner user" do
    subject { described_class.new(User.make!, nil) }
    it { should allows(:index) }
  end
end
