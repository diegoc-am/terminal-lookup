# frozen_string_literal: true

require_relative '../test_helper'

module TerminalLookup
  class TestSearch < TestApp
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

    def test_app_returns_status
      Connections.mysql.transaction(rollback: :always) do
        VCR.use_cassette('andorra_search') do
          Repository::Location.create(@attributes)
          get('/api/v1/search?address=andorra la vella')
          assert(last_response.ok?)
          Approvals.verify(last_response.body, name: 'test_search_is_done', format: :json)
        end
      end
    end
  end
end
