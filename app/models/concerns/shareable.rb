module Shareable
  def facebook_share_url
    "https://www.facebook.com/dialog/share"\
      "?app_id=#{ENV["FACEBOOK_APP_ID"]}"\
      "&redirect_uri=#{URI.escape(self.url)}"\
      "&href=#{URI.escape(self.url)}"\
  end

  def twitter_share_url
    "https://twitter.com/intent/tweet"\
      "?text=#{URI.escape(self.name)}"\
      "&url=#{URI.escape(self.url)}"
  end
end
