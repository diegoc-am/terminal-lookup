# frozen_string_literal: true

require 'grape'
require_relative 'lib/config'

module TerminalLookup
  ##
  # Main API instatiation
  class API < Grape::API
    format :json
    prefix :api

    get '/status' do
      { status: :ok }
    end
  end
end