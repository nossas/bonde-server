
require "rails_helper"

RSpec.describe AuthenticationService do
  let(:user) { User.make! }
  let(:request_mock) do
    double(headers: headers_mock)
  end
  let(:headers_mock) do
    { 'access-token' => 'xyz' }
  end

  describe '#gen_token' do
    subject { AuthenticationService.gen_token(user) }

    let(:headers_mock) do
      { 'access-token' => subject }
    end

    it "should generate a valid jwt token for user" do
      auth_service = AuthenticationService.new(request_mock)
      expect(auth_service.valid_token?).to eq(true)
    end
  end

  describe '.token' do
    subject { AuthenticationService.new(request_mock).token }

    context "when token is present" do
      it { is_expected.to eq('xyz') }
    end

    context "when token is not present" do
      let(:headers_mock) { {} }
      it { is_expected.to eq(nil) }
    end
  end

  describe '.has_token?' do
    subject { AuthenticationService.new(request_mock).has_token? }

    context "when token is present" do
      it { is_expected.to eq(true) }
    end

    context "when has not token" do
      let(:headers_mock) { {} }
      it { is_expected.to eq(false) }
    end
  end

  describe '.valid_token?' do
    subject { AuthenticationService.new(request_mock).valid_token? }

    context "with invalid token" do
      it { is_expected.to eq(false) }
    end

    context "with valid token" do
      let(:headers_mock) do
        { 'access-token' => AuthenticationService.gen_token(user) }
      end
      it { is_expected.to eq(true) }
    end
  end

  describe '.current_user' do
    subject { AuthenticationService.new(request_mock).current_user }

    context "with valid jwt should return user" do
      let(:headers_mock) do
        { 'access-token' => AuthenticationService.gen_token(user) }
      end

      it { is_expected.to eq(user) }
    end

    context "with invalid jwt" do
      it { is_expected.to eq(nil) }
    end
  end
end
