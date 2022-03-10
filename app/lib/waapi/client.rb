# frozen_string_literal: true

require "waapi/oauth"

class WAAPI
  class Response
    attr_reader :raw, :json, :status

    def initialize(raw)
      @raw = raw
      @status = raw.code.to_i
      @json = JSON.parse(raw.body) rescue nil
    end
  end

  class Client
    def initialize(token = nil)
      @token = token || Oauth.new.fetch_and_cache_token
    end

    def get(path)
      uri = URI(path)

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{@token}"
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
        http.request(req)
      }

      Response.new(res)
    end

    def post(path, body)
      uri = URI(path)

      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{@token}"
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      req.body = body

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
        http.request(req)
      }

      Response.new(res)
    end

    def put(path, body)
      uri = URI(path)

      req = Net::HTTP::Put.new(uri)
      req["Authorization"] = "Bearer #{@token}"
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      req.body = body

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
        http.request(req)
      }

      Response.new(res)
    end
  end
end
