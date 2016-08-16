require 'rails_helper'

RSpec.describe ActivistPressureMailer, type: :mailer do
  describe '#thank_you_email' do
    before do
      @user = stub_model User, email: 'fooz@barz.com'

      @mobilization = stub_model(
        Mobilization,
        name: 'My Mobilization Name',
        facebook_share_url: 'http://facebook.com/share',
        twitter_share_url: 'http://twitter.com/share',
        user: @user
      )
    end

    describe 'default sender data' do
      before do
        @widget = stub_model(
          Widget,
          mobilization: @mobilization,
          settings: {
            email_text: 'Thank you for doing this!'
          }
        )

        @activist = stub_model Activist, name: 'Foo Bar', email: 'foo@bar.org'
        @activist_pressure = stub_model ActivistPressure, widget: @widget, activist: @activist
      end

      it 'should send an email to the properly destination' do
        email = ActivistPressureMailer.thank_you_email(@activist_pressure).deliver_now
        expect(email.to).to be_eql([@activist_pressure.activist.email])
      end

      it 'should send an email with the properly sender' do
        email = ActivistPressureMailer.thank_you_email(@activist_pressure).deliver_now
        expect(email.from).to be_eql([@mobilization.user.email])
      end

      it 'should send an email with the properly subject' do
        email = ActivistPressureMailer.thank_you_email(@activist_pressure).deliver_now
        expect(email.subject).to include(@mobilization.name)
      end

      it 'should send an email with the properly body' do
        email = ActivistPressureMailer.thank_you_email(@activist_pressure).deliver_now
        expect(email.body).to include(@widget.settings['email_text'])
      end

      it 'should send an email with a Facebook share link' do
        email = ActivistPressureMailer.thank_you_email(@activist_pressure).deliver_now
        expect(email.body).to include(@mobilization.facebook_share_url)
      end

      it 'should send an email with a Twitter share link' do
        email = ActivistPressureMailer.thank_you_email(@activist_pressure).deliver_now
        expect(email.body).to include(@mobilization.twitter_share_url)
      end
    end

    describe 'sender data from widget settings' do
      before do
        @widget = stub_model(
          Widget,
          mobilization: @mobilization,
          settings: {
            email_text: 'Thank you for doing this!',
            sender_email: 'bar@foo.org',
            sender_name: 'Bar Foo',
            email_subject: 'Fooz Barz Subject'
          }
        )

        @activist = stub_model Activist, name: 'Foo Bar', email: 'foo@bar.org'
        @activist_pressure = stub_model ActivistPressure, widget: @widget, activist: @activist
      end

      it 'should send an email to the properly destination' do
        email = ActivistPressureMailer.thank_you_email(@activist_pressure).deliver_now
        expect(email.to).to be_eql([@activist_pressure.activist.email])
      end

      it 'should send an email with the properly sender' do
        email = ActivistPressureMailer.thank_you_email(@activist_pressure).deliver_now
        expect(email.from).to be_eql([@activist_pressure.widget.settings['sender_email']])
      end

      it 'should send an email with the properly subject' do
        email = ActivistPressureMailer.thank_you_email(@activist_pressure).deliver_now
        expect(email.subject).to include(@activist_pressure.widget.settings['email_subject'])
      end
    end
  end
end
