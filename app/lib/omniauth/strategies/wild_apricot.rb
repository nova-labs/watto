# frozen_string_literal: true

require 'json'
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class WildApricot < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :wildapricot, "wild_apricot"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site => ENV['WA_SITE_URL'],
        :authorize_url => '/sys/login/OAuthLogin',
        :token_url => 'https://oauth.wildapricot.org/auth/token'
      }

      option :authorize_params, {
        :response_type => 'authorization_code',
        :scope => 'contacts_me',
        :claimed_account_id => ENV['WA_ACCOUNT'],
      }

      authorization_header = Base64.strict_encode64("#{ENV['WA_OAUTH_ID']}:#{ENV['WA_OAUTH_SECRET']}")

      option :token_params, {
        :scope => 'contacts_me',
        :headers => {
          'Authorization' => "Basic #{authorization_header}"
        },
      }

      def callback_url
        full_host + script_name + callback_path
      end

      uid { raw_info['Id'].to_s }

      info do
        {
          :email => raw_info['Email'],
          :name => "#{raw_info['FirstName']} #{raw_info['LastName']}"
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("https://api.wildapricot.org/v2/Accounts/#{ENV['WA_ACCOUNT']}/Contacts/Me").parsed
      end

    end
  end
end
OmniAuth.config.add_camelization 'wildapricot', 'WildApricot'

