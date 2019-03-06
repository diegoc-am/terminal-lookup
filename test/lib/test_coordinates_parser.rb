# frozen_string_literal: true

require_relative '../test_helper'
require './src/terminal_lookup/lib/coordinates_parser'

module TerminalLookup
  class TestCoordinatesParser < TestApp
    def test_coordinates_are_parsed
      assert_equal({ latitude: 40.7000000, longitude: -74.0000000 }, CoordinatesParser.parse('4042N 07400W'))
    end

    def test_no_args_are_passed
      assert_nil(CoordinatesParser.parse(nil))
    end

    def test_empty_string
      assert_nil(CoordinatesParser.parse(''))
    end
  end
end
