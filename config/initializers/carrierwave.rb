CarrierWave.configure do |config|
  if Rails.env.development? or Rails.env.test?
    config.storage = :file
    config.enable_processing = Rails.env.development?
  else
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ID'],
      aws_secret_access_key: ENV['AWS_SECRET']
    }
    config.fog_directory = ENV['AWS_BUCKET']
    config.storage = :fog
    config.asset_host = ActionController::Base.asset_host
  end
end