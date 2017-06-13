class MailchimpableFake
  attr_reader :community, :logger

  include Mailchimpable

  class FakeCommunity
    attr_accessor :mailchimp_group_id
    def mailchimp_list_id
      '9989'
    end

    def mailchimp_api_key
      '6846486qwer234w234ela12s124789sd-us4'
    end
  
    def initialize mailchimp_group_id
      self.mailchimp_group_id = mailchimp_group_id
    end
  end

  class Logger
    def error msg
    end
  end

  def initialize mailchimp_group_id: '99899'
    @community = FakeCommunity.new mailchimp_group_id
    @logger = Logger.new
  end
end


RSpec.describe Mailchimpable do
  let(:fake) { MailchimpableFake.new }

  describe '#groupings' do
    it 'mailchimp_group_id = 99899' do
      expect(fake.groupings['99899']).to be true
    end

    it 'null mailchimp_group_id' do
      expect(( MailchimpableFake.new mailchimp_group_id: nil ).groupings).not_to be
    end
  end

  describe '#create_segment' do
    def valid_response
      %(
      {
        "id": "49381",
        "name": "Meu Segmento",
        "member_count": 1,
        "type": "saved",
        "created_at": "2015-09-16 21:32:12",
        "updated_at": "2015-09-16 21:32:12",
        "options": {
          "conditions": [
            {
              "field": "timestamp_opt",
              "op": "greater",
              "value": "last"
            }
          ]
        },
        "list_id": "57afe96172",
        "_links": [
          {
            "rel": "self",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/segments/49381",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Segments/Instance.json"
          },
          {
            "rel": "parent",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/segments",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Segments/Collection.json",
            "schema": "https://api.mailchimp.com/schema/3.0/CollectionLinks/Lists/Segments.json"
          },
          {
            "rel": "delete",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/segments/49381",
            "method": "DELETE"
          },
          {
            "rel": "update",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/segments/49381",
            "method": "PATCH",
            "schema": "https://api.mailchimp.com/schema/3.0/Lists/Segments/Instance.json"
          }
        ]
      })
    end

    it 'timeout' do
      stub_request(:post, "https://us4.api.mailchimp.com/3.0/lists/9989/segments").
         with(:body => "{\"name\":\"Meu Segmento\",\"static_segment\":[]}",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic YXBpa2V5OjY4NDY0ODZxd2VyMjM0dzIzNGVsYTEyczEyNDc4OXNkLXVzNA==', 'Content-Type'=>'application/json'}).
         to_timeout
      expect{fake.create_segment 'Meu Segmento'}.to raise_error(Gibbon::MailChimpError)
    end
    
    it 'net problem' do
      stub_request(:post, "https://us4.api.mailchimp.com/3.0/lists/9989/segments").
         with(:body => "{\"name\":\"Meu Segmento\",\"static_segment\":[]}",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic YXBpa2V5OjY4NDY0ODZxd2VyMjM0dzIzNGVsYTEyczEyNDc4OXNkLXVzNA==', 'Content-Type'=>'application/json'}).
         to_raise(SocketError)
         
      expect{fake.create_segment 'Meu Segmento'}.to raise_error(Gibbon::MailChimpError)
    end
    
    it 'Request ok' do
      stub_request(:post, "https://us4.api.mailchimp.com/3.0/lists/9989/segments").
         with(:body => "{\"name\":\"Meu Segmento\",\"static_segment\":[]}",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic YXBpa2V5OjY4NDY0ODZxd2VyMjM0dzIzNGVsYTEyczEyNDc4OXNkLXVzNA==', 'Content-Type'=>'application/json'}).
         to_return(:status => 200, :body => valid_response, :headers => {})

      ret = fake.create_segment 'Meu Segmento'

      expect(ret).to be 
    end
  end



  describe '#subscribe_to_list' do
    def valid_response
      %({
        "id": "852aaa9532cb36adfb5e9fef7a4206a9",
        "email_address": "fake@nossas.org",
        "unique_email_id": "fab20fa03d",
        "email_type": "html",
        "status": "subscribed",
        "status_if_new": "",
        "merge_fields": {
          "FNAME": "my fake",
          "LNAME": "email"
        },
        "interests": {
          "9143cf3bd1": false,
          "3a2a927344": false,
          "f9c8f5f0ff": false,
          "f231b09abc": false,
          "bd6e66465f": false
        },
        "stats": {
          "avg_open_rate": 0,
          "avg_click_rate": 0
        },
        "ip_signup": "",
        "timestamp_signup": "",
        "ip_opt": "198.2.191.34",
        "timestamp_opt": "2015-09-16 19:24:29",
        "member_rating": 2,
        "last_changed": "2015-09-16 19:24:29",
        "language": "",
        "vip": false,
        "email_client": "",
        "location": {
          "latitude": 0,
          "longitude": 0,
          "gmtoff": 0,
          "dstoff": 0,
          "country_code": "",
          "timezone": ""
        },
        "list_id": "57afe96172",
        "_links": [
          {
            "rel": "self",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/852aaa9532cb36adfb5e9fef7a4206a9",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "parent",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Collection.json",
            "schema": "https://api.mailchimp.com/schema/3.0/CollectionLinks/Lists/Members.json"
          },
          {
            "rel": "update",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/852aaa9532cb36adfb5e9fef7a4206a9",
            "method": "PATCH",
            "schema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "upsert",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/852aaa9532cb36adfb5e9fef7a4206a9",
            "method": "PUT",
            "schema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "delete",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/852aaa9532cb36adfb5e9fef7a4206a9",
            "method": "DELETE"
          },
          {
            "rel": "activity",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/852aaa9532cb36adfb5e9fef7a4206a9/activity",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Activity/Collection.json"
          },
          {
            "rel": "goals",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/852aaa9532cb36adfb5e9fef7a4206a9/goals",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Goals/Collection.json"
          },
          {
            "rel": "notes",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/852aaa9532cb36adfb5e9fef7a4206a9/notes",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Notes/Collection.json"
          }
        ]
      })
    end

    it 'Request ok' do
      stub_request(:put, "https://us4.api.mailchimp.com/3.0/lists/9989/members/4e80eb2636e37dc06d4ad0c542f0becd").
        with(:body => "{\"email_address\":\"fake@nossas.org\",\"status\":\"subscribed\",\"merge_fields\":{\"FNAME\":\"my fake\",\"LNAME\":\"email\"}}",
          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic YXBpa2V5OjY4NDY0ODZxd2VyMjM0dzIzNGVsYTEyczEyNDc4OXNkLXVzNA==', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => valid_response, :headers => {})


      ret = fake.subscribe_to_list 'fake@nossas.org', {FNAME: 'my fake', LNAME: 'email'}, {update_existing: true}

      expect(ret).to be 
    end

    it 'Some error' do
      stub_request(:put, "https://us4.api.mailchimp.com/3.0/lists/9989/members/4e80eb2636e37dc06d4ad0c542f0becd").
        with(:body => "{\"email_address\":\"fake@nossas.org\",\"status\":\"subscribed\",\"merge_fields\":{\"FNAME\":\"my fake\",\"LNAME\":\"email\"}}",
          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic YXBpa2V5OjY4NDY0ODZxd2VyMjM0dzIzNGVsYTEyczEyNDc4OXNkLXVzNA==', 'Content-Type'=>'application/json'}).
        to_timeout

      expect { fake.subscribe_to_list('fake@nossas.org', {FNAME: 'my fake', LNAME: 'email'}, {update_existing: true}) }.to raise_error(Mailchimpable::MailchimpableException)
    end
  end


  describe '#subscribe_to_segment' do
    def valid_response
      %( {
        "id": "06f12badc3b5fffc57576822131ded7c",
        "email_address": "fake@nossas.org",
        "unique_email_id": "b9e87761ed",
        "email_type": "html",
        "status": "subscribed",
        "merge_fields": {
          "FNAME": "my fake",
          "LNAME": "email"
        },
        "stats": {
          "avg_open_rate": 0,
          "avg_click_rate": 0
        },
        "ip_signup": "",
        "timestamp_signup": "",
        "ip_opt": "198.2.191.44",
        "timestamp_opt": "2016-02-10T16:41:47+00:00",
        "member_rating": 2,
        "last_changed": "2016-02-10T16:49:36+00:00",
        "language": "",
        "vip": false,
        "email_client": "",
        "location": {
          "latitude": 0,
          "longitude": 0,
          "gmtoff": 0,
          "dstoff": 0,
          "country_code": "",
          "timezone": ""
        },
        "list_id": "205d96e6b4",
        "_links": [
          {
            "rel": "self",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/segments/457/members",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Segments/Members/Collection.json"
          },
          {
            "rel": "parent",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/segments/457",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Segments/Instance.json"
          },
          {
            "rel": "update",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c",
            "method": "PATCH",
            "schema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "upsert",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c",
            "method": "PUT",
            "schema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "delete",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c",
            "method": "DELETE"
          },
          {
            "rel": "activity",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c/activity",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Activity/Collection.json"
          },
          {
            "rel": "goals",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c/goals",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Goals/Collection.json"
          },
          {
            "rel": "notes",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c/notes",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Notes/Collection.json"
          }
        ]
      } )
    end
    
    it 'Request ok' do
      stub_request(:post, "https://us4.api.mailchimp.com/3.0/lists/9989/segments/123123eq/members").
        with(:body => "{\"email_address\":\"fake@nossas.org\"}",
          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic YXBpa2V5OjY4NDY0ODZxd2VyMjM0dzIzNGVsYTEyczEyNDc4OXNkLXVzNA==', 'Content-Type'=>'application/json'}).
          to_return(:status => 200, :body => valid_response, :headers => {})

      ret = fake.subscribe_to_segment '123123eq', "fake@nossas.org"

      expect(ret).to be 
    end

    it 'Some error' do
      stub_request(:post, "https://us4.api.mailchimp.com/3.0/lists/9989/segments/123123eq1/members").
        with(:body => "{\"email_address\":\"fake@nossas.org\"}",
          :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Basic YXBpa2V5OjY4NDY0ODZxd2VyMjM0dzIzNGVsYTEyczEyNDc4OXNkLXVzNA==', 'Content-Type'=>'application/json'}).
          to_timeout

      expect { fake.subscribe_to_segment '123123eq1', "fake@nossas.org" }.to raise_error(Mailchimpable::MailchimpableException)
    end
  end

  describe '#unsubscribe_from_segment' do
    def valid_response
      %( {
        "id": "06f12badc3b5fffc57576822131ded7c",
        "email_address": "fake@nossas.org",
        "unique_email_id": "b9e87761ed",
        "email_type": "html",
        "status": "subscribed",
        "merge_fields": {
          "FNAME": "my fake",
          "LNAME": "email"
        },
        "stats": {
          "avg_open_rate": 0,
          "avg_click_rate": 0
        },
        "ip_signup": "",
        "timestamp_signup": "",
        "ip_opt": "198.2.191.44",
        "timestamp_opt": "2016-02-10T16:41:47+00:00",
        "member_rating": 2,
        "last_changed": "2016-02-10T16:49:36+00:00",
        "language": "",
        "vip": false,
        "email_client": "",
        "location": {
          "latitude": 0,
          "longitude": 0,
          "gmtoff": 0,
          "dstoff": 0,
          "country_code": "",
          "timezone": ""
        },
        "list_id": "205d96e6b4",
        "_links": [
          {
            "rel": "self",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/segments/457/members",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Segments/Members/Collection.json"
          },
          {
            "rel": "parent",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/segments/457",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Segments/Instance.json"
          },
          {
            "rel": "update",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c",
            "method": "PATCH",
            "schema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "upsert",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c",
            "method": "PUT",
            "schema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "delete",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c",
            "method": "DELETE"
          },
          {
            "rel": "activity",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c/activity",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Activity/Collection.json"
          },
          {
            "rel": "goals",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c/goals",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Goals/Collection.json"
          },
          {
            "rel": "notes",
            "href": "https://usX.api.mailchimp.com/3.0/lists/205d96e6b4/members/06f12badc3b5fffc57576822131ded7c/notes",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Notes/Collection.json"
          }
        ]
      } )
    end
    
    it 'Request ok' do
      stub_request(:delete, "https://us4.api.mailchimp.com/3.0/lists/9989/segments/123123eq/members/4e80eb2636e37dc06d4ad0c542f0becd").
        to_return(:status => 204, :body => "", :headers => {})

      ret = fake.unsubscribe_from_segment '123123eq', "fake@nossas.org"

      expect(ret).to be 
    end

    it 'Some error' do
      stub_request(:delete, "https://us4.api.mailchimp.com/3.0/lists/9989/segments/123123eq1/members/4e80eb2636e37dc06d4ad0c542f0becd").
        to_timeout

      expect { fake.unsubscribe_from_segment '123123eq1', "fake@nossas.org" }.to raise_error(Mailchimpable::MailchimpableException)
    end
  end

  describe '#update_member' do
    def valid_response
      %({
        "id": "20dbbf20d91106a9377bb671ba83f381",
        "email_address": "fake@nossas.org",
        "unique_email_id": "50c27a90af",
        "email_type": "html",
        "status": "unsubscribed",
        "status_if_new": "",
        "merge_fields": {
          "FNAME": "my fake",
          "LNAME": "email"
        },
        "interests": {
          "9143cf3bd1": false,
          "3a2a927344": false,
          "f9c8f5f0ff": false,
          "f231b09abc": false,
          "bd6e66465f": false
        },
        "stats": {
          "avg_open_rate": 0,
          "avg_click_rate": 0
        },
        "ip_signup": "",
        "timestamp_signup": "",
        "ip_opt": "198.2.191.34",
        "timestamp_opt": "2015-09-16 20:23:55",
        "member_rating": 2,
        "last_changed": "2015-09-16 20:25:26",
        "language": "",
        "vip": false,
        "email_client": "",
        "location": {
          "latitude": 0,
          "longitude": 0,
          "gmtoff": 0,
          "dstoff": 0,
          "country_code": "",
          "timezone": ""
        },
        "list_id": "57afe96172",
        "_links": [
          {
            "rel": "self",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/20dbbf20d91106a9377bb671ba83f381",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "parent",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Collection.json",
            "schema": "https://api.mailchimp.com/schema/3.0/CollectionLinks/Lists/Members.json"
          },
          {
            "rel": "update",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/20dbbf20d91106a9377bb671ba83f381",
            "method": "PATCH",
            "schema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "upsert",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/20dbbf20d91106a9377bb671ba83f381",
            "method": "PUT",
            "schema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Instance.json"
          },
          {
            "rel": "delete",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/20dbbf20d91106a9377bb671ba83f381",
            "method": "DELETE"
          },
          {
            "rel": "activity",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/20dbbf20d91106a9377bb671ba83f381/activity",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Activity/Collection.json"
          },
          {
            "rel": "goals",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/20dbbf20d91106a9377bb671ba83f381/goals",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Goals/Collection.json"
          },
          {
            "rel": "notes",
            "href": "https://usX.api.mailchimp.com/3.0/lists/57afe96172/members/20dbbf20d91106a9377bb671ba83f381/notes",
            "method": "GET",
            "targetSchema": "https://api.mailchimp.com/schema/3.0/Lists/Members/Notes/Collection.json"
          }
        ]
      })
    end

    it 'Request ok' do
      stub_request(:patch, "https://us4.api.mailchimp.com/3.0/lists/9989/members/4e80eb2636e37dc06d4ad0c542f0becd").
        with(:body => "{\"interests\":{\"1234212\":true,\"12312\":true}}").
        to_return(:status => 200, :body => valid_response, :headers => {})

      ret = fake.update_member 'fake@nossas.org', {groupings: {'1234212': true, '12312': true}}

      expect(ret).to be 
    end

    it 'Problem' do
      stub_request(:patch, "https://us4.api.mailchimp.com/3.0/lists/9989/members/4e80eb2636e37dc06d4ad0c542f0becd").
        with(:body => "{\"interests\":{\"1234212\":true,\"12312\":true}}").
        to_timeout

      expect { fake.update_member 'fake@nossas.org', {groupings: {'1234212': true, '12312': true}} }.to raise_error(Mailchimpable::MailchimpableException)
    end
  end

  describe '#status_on_list' do

    def valid_response status 
%Q({ 
  "id": "2b5a209483eb26743e862f736d80f96b", 
  "email_address": "fake@nossas.org", 
  "unique_email_id": "4e80eb2636e", 
  "email_type": "html", 
  "status": "#{status}", 
  "merge_fields": {
    "FNAME": "Fake", 
    "LNAME": "Man", 
    "ORG": "TESTE", 
    "CITY": "Pindonhangaba"
  }, 
  "interests": {
    "bcde6938c1": false, 
    "bcde6938c2": false, 
    "bcde6938c3": false
  }, 
  "stats": {
    "avg_open_rate": 0, 
    "avg_click_rate": 0
  }
})
    end

    it 'Subscribed on list' do
      stub_request(:get, "https://us4.api.mailchimp.com/3.0/lists/9989/members/4e80eb2636e37dc06d4ad0c542f0becd").
        to_return(:status => 200, :body => valid_response('subscribed'), :headers => {})

      ret = fake.status_on_list 'fake@nossas.org'

      expect(ret).to be :subscribed
    end

    it 'Unsubscribed on list' do
      stub_request(:get, "https://us4.api.mailchimp.com/3.0/lists/9989/members/4e80eb2636e37dc06d4ad0c542f0becd").
        to_return(:status => 200, :body => valid_response('unsubscribed'), :headers => {})

      ret = fake.status_on_list 'fake@nossas.org'

      expect(ret).to be :unsubscribed
    end

    it 'don\'t exist' do
      stub_request(:get, "https://us4.api.mailchimp.com/3.0/lists/9989/members/4e80eb2636e37dc06d4ad0c542f0becd").
        to_return(:status => 404, :body => "", :headers => {})

      expect( fake.status_on_list 'fake@nossas.org' ).to be :not_registred
    end

    it 'Other Problem' do
      stub_request(:get, "https://us4.api.mailchimp.com/3.0/lists/9989/members/4e80eb2636e37dc06d4ad0c542f0becd").
        to_timeout

      expect { fake.status_on_list 'fake@nossas.org' }.to raise_error(Mailchimpable::MailchimpableException)
    end
  end
end
