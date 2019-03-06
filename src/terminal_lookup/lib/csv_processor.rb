# frozen_string_literal: true

require 'csv'
require 'date'
require_relative 'coordinates_parser'
require_relative '../model/location'

module TerminalLookup
  class CSVProcessor
    COLUMNS = %i[
      change
      country_code
      identifier
      name
      name_without_diacritics
      subdiv
      function
      status
      date
      iata
      location
      remarks
      locode
    ].freeze

    class << self
      def run(file)
        CSV.foreach(
          file.is_a?(String) ? file : file.path, encoding: 'iso-8859-1:utf-8'
        ).each_with_object([]) do |row, array|
          parsed_row = parse_row(row)

          array << Model::Location.new(parsed_row)
        rescue Dry::Struct::Error
          # ignore
        end
      end

      private

      def parse_row(row)
        COLUMNS
          .zip(row)
          .each_with_object({}) { |(k, v), h| h[k] = v }
          .tap do |h|
            h[:locode] = "#{h[:country_code]}#{h[:identifier]}"
            h[:date] = parse_date(h[:date])
            h[:location] = CoordinatesParser.parse(h[:location])
            h[:function] = h[:function]&.gsub('-', '')&.split('')
          end
      end

      def parse_date(date_string)
        return unless date_string

        year = Integer(date_string[0..1]&.to_i)
        month = Integer(date_string[2..3]&.to_i)

        # The first issue of UN/LOCODES was in the year 1981
        # We're assuming that if the year is bigger than 80 it's from
        # the preovious century
        year = year > 80 ? year + 190_0 : year + 200_0

        Date.new(year, month)
      end
    end
  end
end
