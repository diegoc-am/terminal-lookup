# frozen_string_literal: true

module TerminalLookup
  ##
  # Parses the coordinates
  class CoordinatesParser
    class << self
      def parse(coordinates)
        return unless coordinates
        return if coordinates.empty?

        latitude, longitude = coordinates.split(' ').map { |coord| dms_to_d(coord) }
        { latitude: latitude, longitude: longitude }
      end

      def dms_to_d(coordinate)
        direction = coordinate[-1].downcase.to_sym

        parsed_coordinate = coordinate[0...-1].rjust(5, '0')

        # decimal_value = degrees + minutes / 60
        decimal_value = Float(parsed_coordinate[0..2]) + Float(parsed_coordinate[3..-1]) / 60.0

        case direction
        when :s, :w
          -1 * decimal_value
        when :n, :e
          decimal_value
        end
      end
    end
  end
end
