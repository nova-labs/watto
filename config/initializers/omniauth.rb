# frozen_string_literal: true

require "#{Rails.root}/app/lib/omniauth/strategies/wild_apricot"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :wildapricot, ENV['WA_OAUTH_ID'], ENV['WA_OAUTH_SECRET'], :callback_path => "/callback/wildapricot"
end
