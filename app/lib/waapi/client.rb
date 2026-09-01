# frozen_string_literal: true

require "waapi/oauth"

class WAAPI
  class Error < StandardError; end

  class Response
    attr_reader :raw, :json, :status

    def initialize(raw)
      @raw = raw
      @status = raw.code.to_i
      @json = JSON.parse(raw.body) rescue nil
    end
  end

  class PaginatedResponse
    attr_reader :json

    def to_s
      "PaginatedResponse with #{@json&.count} records"
    end

    def add_page(arr)
      @json ||= []
      @json.concat(arr)
    end
  end

  class Client
    def initialize(token = nil)
      @token = token || Oauth.new.fetch_and_cache_token
    end

    def download_image(path)
      uri = URI(path)

      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{@token}"

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      if res.code.to_i == 200
        res.body  # This is the binary image data
      else
        raise "Failed to download image: #{res.code} #{res.message}"
      end
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

    def add_paging(url, top:, skip:)
      uri = URI.parse(url.to_s)
      existing = uri.query ? CGI.parse(uri.query) : {}

      # Override or insert paging params
      existing["$top"]  = [top.to_s]
      existing["$skip"] = [skip.to_s]

      # Flatten back to an array of pairs to preserve multi-valued params
      pairs = existing.flat_map { |k, vals| Array(vals).map { |v| [k, v] } }

      # Rebuild query and return the full string (fragment preserved automatically)
      uri.query = URI.encode_www_form(pairs)
      uri.to_s.gsub("%24", "$")
    end

    def get_all(path)
      page_size = 100
      skip = 0

      full_response = PaginatedResponse.new

      loop do
        page_path = add_paging(path, top: page_size, skip: skip)
        # The $select list can run to thousands of characters, so keep the
        # progress line readable -- the paging params are the useful part.
        puts "--> Getting #{page_path.sub(/\$select=[^&]*/, "$select=...")}"
        res = get(page_path)

        unless res.status == 200
          message = res.json.is_a?(Hash) ? (res.json["Message"] || res.json["message"]) : nil
          raise Error, "Wild Apricot returned HTTP #{res.status} for #{page_path}: #{message || res.raw.body.to_s[0, 200]}"
        end

        # Sometimes WA returns an array for the APIs that need to be paginated,
        # but other times it is a hash with a top level key. Lets guess at what
        # it is and combine them.
        items = case res.json
                when Array then res.json
                when Hash then res.json[res.json.keys.first] # guess the key for the array returned
                end

        # Guessing the key only works when the body really is a page of
        # records, so say so plainly rather than failing on the value later.
        unless items.is_a? Array
          raise Error, "Expected a list of records from #{page_path}, got #{items.class}: #{res.raw.body.to_s[0, 200]}"
        end

        puts "--> got #{items.count}"
        break if items.empty?

        full_response.add_page items

        break if items.length < page_size
        skip += page_size
      end

      full_response
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
