# frozen_string_literal: true

require_relative '../lib/connections'
require_relative '../model/location'

module TerminalLookup
  module Repository
    ##
    # Database communication layer to manage the locations
    class Location
      DB = Connections.mysql

      class << self
        def create(attributes) # rubocop:disable Metrics/AbcSize
          attrs = attributes.to_h

          model = Model::Location.new(attributes) # ensure data sanity

          function = attrs.delete(:function)
          attrs[:location] = Sequel.lit("Point(#{attrs[:location][:latitude]}, #{attrs[:location][:longitude]})")

          DB.transaction(rollback: :reraise) do
            DB[:locations].insert(attrs)
            function.each { |f| DB[:functions].insert(locode: attrs[:locode], function: f) }
          end

          model
        end

        def create_multiple(elements, ignore_repeated_elements: true)
          DB.transaction(rollback: :reraise) do
            Array(elements).each { |e| create(e) }
          rescue Sequel::UniqueConstraintViolation
            raise unless ignore_repeated_elements
          end
        end

        def find(locode:)
          result = DB[:locations]
                   .where(locode: locode)
                   .select_append(Sequel.lit('ST_X(location)'), Sequel.lit('ST_Y(location)'))
                   .first

          result[:function] = DB[:functions].where(locode: locode).select(:function).map(:function)

          to_model(result)
        end

        def find_multiple(locodes:) # rubocop:disable Metrics/AbcSize
          locations = DB[:locations]
                      .where(locode: locodes)
                      .select_append(Sequel.lit('ST_X(location)'), Sequel.lit('ST_Y(location)'))

          functions = DB[:functions]
                      .where(locode: locodes)
                      .each_with_object(Hash.new([])) { |row, h| h[row[:locode]] << row[:function] }

          locations.map do |location|
            location[:function] = functions[location[:locode]]
            to_model(location)
          end
        end

        def closest_locations(point:, radius: 50_000, limit: 10) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          distance = radius / 100 / 111
          results = DB[:locations].select(
            :locode,
            Sequel.as(
              Sequel.lit(
                "ST_Distance_Sphere(Point(#{point[:latitude]}, #{point[:longitude]}), location)"
              ), :distance_in_meters
            )
          ).where(
            Sequel.lit(
              <<~SQL
                ST_Contains(
                  ST_MakeEnvelope(
                    Point(#{point[:latitude]} + #{distance}, #{point[:longitude]} + #{distance}),
                    Point(#{point[:latitude]} - #{distance}, #{point[:longitude]} - #{distance})
                  ), location
                )
              SQL
            )
          ).order(:distance_in_meters).limit(limit).each_with_object({}) do |row, h|
            h[row[:locode]] = row[:distance_in_meters]
          end

          find_multiple(locodes: results.keys).map do |e|
            { location: e, distance_in_meters: results[e.locode] }
          end
        end

        private

        def to_model(element)
          element[:location] = {
            latitude: element.delete(:"ST_X(location)"),
            longitude: element.delete(:"ST_Y(location)")
          }

          Model::Location.new(element)
        end
      end
    end
  end
end
