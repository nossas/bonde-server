require "rails_helper"

RSpec.describe DonationsMailer, type: :mailer do
  describe "#thank_you_email" do
    before do
      @user = stub_model(User, email: "fooz@barz.com")
      @community = stub_model(Community, name: "Meu Rio")
      @mobilization = stub_model(
        Mobilization, name: "My Mobilization Name",
        facebook_share_url: "http://facebook.com/share",
        twitter_share_url: "http://twitter.com/share",
        user: @user,
        custom_domain: 'localhost.dev',
        community: @community
      )
      @widget = stub_model(
        Widget, mobilization: @mobilization,
        kind: 'donation',
        settings: {email_text: "Thank you for doing this!"}
      )

      @donation = stub_model Donation, widget: @widget, customer: { email: 'donor@foobar.com' }
    end

    it "should deliver a message from mobilization's creator" do
      email = DonationsMailer.thank_you_email(@donation, true).deliver_now
      expect(email.from).to eq([@mobilization.user.email])
    end

    it "should deliver a message to donor" do
      email = DonationsMailer.thank_you_email(@donation, true).deliver_now
      expect(email.to).to eq([@donation.customer['email']])
    end

    it "should send an email with the properly subject" do
      email = DonationsMailer.thank_you_email(@donation, true).deliver_now
      expect(email.subject).to include(@mobilization.name)
    end
  end
end
