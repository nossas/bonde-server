class UploadsController < ApplicationController
  respond_to :json

  def index
    storage = Fog::Storage.new({
      :provider              => 'AWS',
      :aws_access_key_id     => ENV['AWS_ID'],
      :aws_secret_access_key => ENV['AWS_SECRET']
    })
    options = {path_style: true}
    headers = {"Content-Type" => params[:contentType], "x-amz-acl" => "public-read"}
    url = storage.put_object_url(ENV['AWS_BUCKET'], "uploads/#{params[:objectName]}", 15.minutes.from_now.to_time.to_i, headers, options)
    render json: {signedUrl: url}
  end
end
