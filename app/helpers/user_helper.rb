# frozen_string_literal: true

module UserHelper
  def gravatar_url(user, size=200)
    gravatar_id = Digest::MD5.hexdigest(user.email)
    "https://gravatar.com/avatar/#{gravatar_id}.png?d=mp&s=#{size}"
  end
end
