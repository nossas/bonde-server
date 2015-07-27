class UploadsController < ApplicationController
  respond_to :json
  after_action :verify_policy_scoped, only: %i[]

  def index
    authorize :upload
    storage = Fog::Storage.new({
      :provider              => 'AWS',
      :aws_access_key_id     => ENV['AWS_ID'],
      :aws_secret_access_key => ENV['AWS_SECRET']
    })
    options = {path_style: true}
    headers = {"Content-Type" => params[:contentType], "x-amz-acl" => "public-read"}
    url = storage.put_object_url(ENV['AWS_BUCKET'], "uploads/#{Time.now.to_i}_#{params[:objectName]}", 15.minutes.from_now.to_time.to_i, headers, options)
    render json: {signedUrl: url}
  end
end
