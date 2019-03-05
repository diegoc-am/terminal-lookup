# frozen_string_literal: true

require 'mysql2'
require 'sequel'
require_relative 'config'

module TerminalLookup
  ##
  # Manages the connections
  class Connections
    MYSQL = ::Sequel.connect(
      Config.mysql.url,
      max_connections: Config.mysql.max_connections
    ).freeze
    private_constant :MYSQL
    class << self
      def mysql
        MYSQL
      end
    end
  end
end
