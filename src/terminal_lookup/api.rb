# frozen_string_literal: true

require 'grape'
require_relative 'lib/config'
require_relative 'lib/connections'
require_relative 'business_logic/find_nearby_terminals'

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

    params do
      requires :address, type: String
      optional :radius, type: Integer, default: 50_000
      optional :limit, type: Integer, default: 10
    end
    get '/search' do
      BusinessLogic::FindNearbyTerminals.new(
        address: params['address'],
        radius: params['radius'],
        limit: params['limit']
      ).run.map do |e|
        e[:location] = e[:location].to_h
        e
      end
    end
  end
end
