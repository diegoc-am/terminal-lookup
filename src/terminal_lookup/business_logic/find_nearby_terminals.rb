# frozen_string_literal: true

require_relative '../repository/geocoding'
require_relative '../repository/location'

module TerminalLookup
  module BusinessLogic
    ##
    # Finds nearby terminals
    class FindNearbyTerminals
      LOGGER = ::Logger.new(STDOUT, level: Config.log.level)

      def initialize(address:, limit: 10, radius: 50_000)
        @address = address
        @limit = limit
        @radius = radius
      end

      def run
        point = coordinates
        return [] unless point

        LOGGER.info("Searching for #{point}")

        Repository::Location.closest_locations(point: point, radius: @radius, limit: @limit)
      end

      private

      def coordinates
        latitude, longitude = @address.split(',').map { |e| Float(e) }.first(2)
        { latitude: latitude, longitude: longitude }
      rescue ArgumentError, TypeError
        LOGGER.info("Searching for #{@address}")
        Repository::Geocoding.search(address: @address)
      end
    end
  end
end
