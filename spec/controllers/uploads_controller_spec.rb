require 'rails_helper'

RSpec.describe UploadsController, type: :controller do
  describe "GET #index" do
    it "should return signed URL to PUT file on S3" do
      ENV['AWS_ID'] = 'foo'
      ENV['AWS_SECRET'] = 'bar'
      ENV['AWS_BUCKET'] = 'foobar'
      Fog.mock!
      storage = Fog::Storage.new({
        :provider              => 'AWS',
        :aws_access_key_id     => ENV['AWS_ID'],
        :aws_secret_access_key => ENV['AWS_SECRET']
      })
      options = {path_style: true}
      headers = {"Content-Type" => "image/jpeg", "x-amz-acl" => "public-read"}
      url = storage.put_object_url(ENV['AWS_BUCKET'], "uploads/foo_bar", 15.minutes.from_now.to_time.to_i, headers, options)
      get :index, contentType: 'image/jpeg', objectName: 'foo_bar', format: :json
      expect(response.body).to include('foobar')
      expect(response.body).to include('uploads/foo_bar')
      expect(response.body).to include('Amz-Signature=')
    end
  end
end
