# frozen_string_literal: true

require_relative 'types'

module TerminalLookup
  module Model
    ##
    # Location model
    class Location < Dry::Struct
      attribute :country_code, Types::Strict::String
      attribute :identifier, Types::Strict::String
      attribute :change, Types::Strict::String.optional.default(nil)
      attribute :name, Types::Strict::String
      attribute :function, Types::Strict::Array.optional.default([])
      attribute :name_without_diacritics, Types::Strict::String
      attribute :subdiv, Types::Strict::String.optional.default(nil)
      attribute :date, Types::Strict::Date.optional.default(nil)
      attribute :iata, Types::Strict::String.optional.default(nil)
      attribute :remarks, Types::Strict::String.optional.default(nil)
      attribute :status, Types::Strict::String.optional.default(nil)
      attribute :location do
        attribute :latitude, Types::Coercible::Float
        attribute :longitude, Types::Coercible::Float
      end.optional.default(nil)
      attribute :locode, Types::Strict::String
    end
  end
end
