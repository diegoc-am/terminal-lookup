# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'test'

require 'simplecov'

SimpleCov.start { add_filter(%w[test vendor]) }
SimpleCov.minimum_coverage(82)

require 'minitest/autorun'
require 'minitest/reporters'
require 'rack/test'
require 'approvals'
require 'pry'
require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

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
