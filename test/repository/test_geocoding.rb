# frozen_string_literal: true

require_relative '../test_helper'
require './src/terminal_lookup/repository/geocoding'

module TerminalLookup
  module Repository
    class TestGeocoding < TestApp
      def test_search
        VCR.use_cassette('test_search') do
          result = Geocoding.search(address: 'Statue of Liberty')

          assert_equal('40.6892532', result[:latitude])
          assert_equal('-74.0445481714432', result[:longitude])
        end
      end

      def test_finding_an_address_that_does_not_exist
        VCR.use_cassette('test_finding_an_address_that_does_not_exist') do
          result = Geocoding.search(address: 'ahsgdbfhjasbdfhbaskdfbahkjsdbfhkjabsdkjfbasjhkdbfkasd')

          assert_nil(result)
        end
      end
    end
  end
end
