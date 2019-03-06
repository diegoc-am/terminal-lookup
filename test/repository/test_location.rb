# frozen_string_literal: true

require_relative '../test_helper'
require './src/terminal_lookup/repository/location'

module TerminalLookup
  module Repository
    class TestLocation < TestApp
      def setup # rubocop:disable Metrics/MethodLength
        @attributes = {
          change: nil,
          country_code: 'AD',
          identifier: 'ALV',
          name: 'Andorra la Vella',
          name_without_diacritics: 'Andorra la Vella',
          subdiv: nil,
          function: %w[3 4 6],
          status: 'AI',
          date: Date.new(2_016, 1),
          iata: nil,
          location: { latitude: 42.5, longitude: 1.5166666666666666 },
          remarks: '',
          locode: 'ADALV'
        }
      end

      def test_create
        Connections.mysql.transaction(rollback: :always) do
          assert_equal(@attributes, Location.create(::TerminalLookup::Model::Location.new(@attributes)).to_h)
        end
      end

      def test_find
        Connections.mysql.transaction(rollback: :always) do
          Location.create(::TerminalLookup::Model::Location.new(@attributes))
          assert_equal(@attributes, Location.find(locode: @attributes[:locode]).to_h)
        end
      end
    end
  end
end
