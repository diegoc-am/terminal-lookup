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
        def create(attributes)
          attrs = attributes.to_h

          model = Model::Location.new(attributes) # ensure data sanity

          DB.transaction(rollback: :reraise) do
            function = attrs.delete(:function)
            attrs[:location] = Sequel.lit("Point(#{attrs[:location][:latitude]}, #{attrs[:location][:longitude]})")
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

          result[:location] = {
            latitude: result.delete(:"ST_X(location)"),
            longitude: result.delete(:"ST_Y(location)")
          }

          Model::Location.new(result)
        end

        def closest_locations(point:, radius: 50_000, limit: 10)
          distance = radius / 100 / 111
          DB[:locations].select(
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
          ).order(:distance_in_meters).limit(10).map do |e|
            { location: find(locode: e[:locode]), distance_in_meters: e[:distance_in_meters] }
          end
        end
      end
    end
  end
end
