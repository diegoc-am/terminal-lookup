# frozen_string_literal: true

require_relative '../test_helper'

class TestStatus < TestApp
  def test_app_returns_status
    get('/api/v1/status')
    assert(last_response.ok?)
    Approvals.verify(last_response.body, name: 'test_app_returns_status', format: :json)
  end
end
