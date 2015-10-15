require 'rails_helper'

class Fake
  include Herokuable
end

RSpec.describe Herokuable do
  before do
    @fake = Fake.new
    @user1 = User.make!
    stub_current_user(@user1)
  end

  describe "Create domain" do
    it "should call Heroku's API to create a custom domain" do
      @domain = {hostname: "test.com"}
      @url = "https://api.heroku.com/apps/#{ENV['CLIENT_APP_NAME']}/domains"
      @fake.create_domain(@domain)
      expect(WebMock).to have_requested(:post, @url).with(body: @domain)
    end
  end

  describe "Delete domain" do
    it "should call Heroku's API to delete a custom domain" do
      @domain = "test.com"
      @url = "https://api.heroku.com/apps/#{ENV['CLIENT_APP_NAME']}/domains/#{@domain}"
      stub_request(:delete, @url)
      @fake.delete_domain(@domain)
      expect(WebMock).to have_requested(:delete, @url)
    end
  end
end
