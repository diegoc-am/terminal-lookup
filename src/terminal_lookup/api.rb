# frozen_string_literal: true

require 'grape'
require_relative 'lib/config'
require_relative 'lib/connections'

module TerminalLookup
  ##
  # Main API instatiation
  class API < Grape::API
    version :v1, using: :path
    format :json
    prefix :api

    get '/status' do
      { status: :ok }
    end
  end
end
