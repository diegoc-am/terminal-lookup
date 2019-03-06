# frozen_string_literal: true

require_relative '../test_helper'
require './src/terminal_lookup/lib/csv_processor'

module TerminalLookup
  class TestCSVProcessor < TestApp
    def setup
      @file = File.new('./test/fixtures/csv_unlocodes/2018-2 UNLOCODE CodeListPart1.csv')
    end

    def test_csv_is_parsed
      result = CSVProcessor.run(@file)
      assert(result.is_a?(Array))
      assert_equal(42_039, result.size)
      result.each { |e| assert(e.is_a?(::TerminalLookup::Model::Location)) }
    end
  end
end
