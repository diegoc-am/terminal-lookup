# frozen_string_literal: true

require 'simplecov'

SimpleCov.start { add_filter(%w[test vendor]) }
SimpleCov.minimum_coverage(82)

require 'minitest/autorun'
require 'minitest/reporters'
require 'rack/test'
require 'approvals'

Approvals.configure do |config|
  config.approvals_path = 'test/fixtures/approvals/'
end

Minitest::Reporters.use!

OUTER_APP = Rack::Builder.parse_file('config.ru').first

class TestApp < Minitest::Test
  include Rack::Test::Methods

  def app
    OUTER_APP
  end
end
