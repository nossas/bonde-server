module Shareable
  def facebook_share_url
    "https://www.facebook.com/dialog/share"\
      "?app_id=#{ENV["FACEBOOK_APP_ID"]}"\
      "&href=#{URI.escape(self.url)}"\
      "&redirect_uri=#{URI.escape(self.url)}"\
  end

  def twitter_share_link
    "https://twitter.com/intent/tweet"\
      "?text=#{URI.escape(self.name)}"\
      "&url=#{URI.escape(self.url)}"
  end
end
