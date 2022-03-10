# frozen_string_literal: true

require "faraday"

class WAAPI
  class Oauth
    CACHE_KEY = "waapi-oauth-token"
    ENDPOINT = "https://oauth.wildapricot.org/auth/token"
    AUTH_SCOPE = [
      :contacts,
      :finances,
      :events,
      :account,
      :event_registrations_view,
    ].join(" ")

    attr_reader :api_key, :auth_scope, :token, :expires_in, :refresh_token

    def initialize(config = {})
      @api_key = config.fetch(:api_key) { WAAPI.config_api_key }
      @auth_scope = config.fetch(:auth_scope, AUTH_SCOPE)
    end

    def fetch_token
      req = connection.post(ENDPOINT, params)
      @body = JSON.parse(req.body)
      @token = @body["access_token"]
      @expires_in = @body["expires_in"]
      @refresh_token = @body["refresh_token"]

      token
    end

    def fetch_and_cache_token
      # Read cache in two steps because we need to know the expires_in for TTL
      cached_token = Rails.cache.read(CACHE_KEY)
      return cached_token if cached_token

      fetch_token

      Rails.cache.write(CACHE_KEY, token, expires_in: expires_in.seconds, race_condition_ttl:3)

      token
    end

  private

    def authorization_header
      "Basic #{credentials}"
    end

    def credentials
      ::Base64.encode64("APIKEY:#{api_key}").strip
    end

    def params
      {
        grant_type: "client_credentials",
        scope: auth_scope,
        obtain_refresh_token: true,
      }
    end

    def connection
      Faraday.new(url: ENDPOINT) do |c|
        c.request :url_encoded
        c.headers["Authorization"] = authorization_header
        c.headers["Accept"] = "application/json"
        c.adapter :net_http
      end
    end
  end
end
