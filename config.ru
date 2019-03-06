# frozen_string_literal: true

require 'rack'
require 'rack/contrib'
require_relative 'src/terminal_lookup/api'

use Rack::TryStatic,
    root: File.expand_path('public', __dir__),
    urls: %w[/], try: ['.html', 'index.html', '/index.html']

run TerminalLookup::API
