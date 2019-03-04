# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require 'dotenv'

require 'deep_open_struct_with_key_access'

module TerminalLookup
  ##
  # Holds the configuration in memory
  class Config
    Dotenv.load(*Dir['config/.env.local', "config/.env.#{ENV['RACK_ENV']}"])

    CONFIG = DeepOpenStructWithKeyAccess.new({}).freeze

    private_constant :CONFIG

    class << self
      def method_missing(method_name, *args, &block)
        if CONFIG.respond_to?(method_name)
          CONFIG.public_send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, *args)
        CONFIG.respond_to?(method_name) || super
      end
    end
  end
end
