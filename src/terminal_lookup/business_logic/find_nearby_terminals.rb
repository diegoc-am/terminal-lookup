# frozen_string_literal: true

require_relative '../repository/geocoding'
require_relative '../repository/location'

module TerminalLookup
  module BusinessLogic
    class FindNearbyTerminals
      def initialize(address:, limit: 10, radius: 50_000)
        @address = address
        @limit = limit
        @radius = radius
      end

      def run
        point = Repository::Geocoding.search(address: @address)
        raise unless point

        Repository::Location.closest_locations(point: point, radius: @radius, limit: @limit)
      end
    end
  end
end
