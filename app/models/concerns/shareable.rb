module Shareable
  def facebook_share_url
    "http://www.facebook.com/sharer.php?u=#{URI.escape(self.url)}"
  end

  def twitter_share_url
    "https://twitter.com/intent/tweet"\
      "?text=#{URI.escape(self.name)}"\
      "&url=#{URI.escape(self.url)}"
  end
end
