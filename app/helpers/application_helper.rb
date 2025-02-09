module ApplicationHelper
  def gravatar_url(email, size: 256)
    hash = Digest::MD5.hexdigest(email.strip.downcase)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=mp"
  end
end
