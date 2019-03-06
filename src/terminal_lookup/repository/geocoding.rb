# frozen_string_literal: true

require 'set'
require 'json'
require 'faraday'
require 'net/http/persistent'
require_relative '../lib/config'

module TerminalLookup
  module Repository
    ##
    # Geocoding Lookup
    class Geocoding
      CONNECTION = Faraday.new(url: Config.geocoding.base_url) do |conn|
        conn.response :logger, Logger.new(STDOUT, level: Config.log.level)
        conn.adapter :net_http_persistent
      end
      private_constant :CONNECTION

      VALID_STATUS = Set.new([200])
      private_constant :VALID_STATUS

      class << self
        def search(address:)
          response = query(address)

          return nil unless VALID_STATUS.include?(response.status)

          extract_coordinates(response.body)
        end

        private

        def query(address)
          CONNECTION.get do |req|
            req.url(Config.geocoding.endpoint)
            req.params['key'] = Config.geocoding.api_token
            req.params['format'] = Config.geocoding.format
            req.params['q'] = address
          end
        end

        def extract_coordinates(json_body)
          # optimistic approach
          result = JSON.parse(json_body).first

          { latitude: result['lat'], longitude: result['lon'] }
        end
      end
    end
  end
end
