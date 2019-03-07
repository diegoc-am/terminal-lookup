# frozen_string_literal: true

namespace :db do # rubocop:disable Metrics/BlockLength
  require 'logger'
  require_relative 'src/terminal_lookup/lib/connections'
  Sequel.extension :migration
  DB = Sequel.connect(TerminalLookup::Config.mysql.url).tap { |db| db.logger = Logger.new($stdout) }.freeze
  FIRST_MIGRATION_DATE = 20_190_305

  desc 'Prints current schema version'
  task :version do
    if DB.tables.include?(:schema_migrations)
      puts "Schema Version: #{DB[:schema_migrations].order(:filename).last[:filename]}"
    else
      puts 'Schema not initialized'
    end
  end

  desc 'Perform migration up to latest migration available'
  task :migrate do
    Sequel::Migrator.run(DB, 'db/migrations', use_transactions: true)
    Rake::Task['db:version'].execute
  end

  desc 'Perform rollback to specified target or full rollback as default'
  task :rollback, :target do |_t, args|
    args.with_defaults(target: FIRST_MIGRATION_DATE)

    Sequel::Migrator.run(DB, 'db/migrations', target: args[:target].to_i, use_transactions: true)
    Rake::Task['db:version'].execute
  end

  desc 'Perform migration reset (full rollback and migration)'
  task :reset do
    Sequel::Migrator.run(DB, 'db/migrations', target: FIRST_MIGRATION_DATE, use_transactions: true)
    Sequel::Migrator.run(DB, 'db/migrations', use_transactions: true)
    Rake::Task['db:version'].execute
  end
end

task :import_locodes do
  require 'down'
  require 'zip'
  require_relative 'src/terminal_lookup/lib/csv_processor'
  require_relative 'src/terminal_lookup/repository/location'

  UN_LOCODES_URL = 'https://www.unece.org/fileadmin/DAM/cefact/locode/loc182csv.zip'

  tempfile = Down.download(UN_LOCODES_URL)

  Zip::File.open(tempfile) do |zip_file|
    zip_file.each do |entry|
      next unless entry.name.include?('CodeListPart')

      file = Tempfile.new
      entry.extract(file) { true } # proc to overwrite the file
      TerminalLookup::Repository::Location.create_multiple(TerminalLookup::CSVProcessor.run(file))
      file.unlink
    end
  end

  tempfile.unlink
end

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test*.rb']
  t.verbose = true
  t.warning = false
end

task build: [:test]

begin
  require 'bundler/audit/task'
  Bundler::Audit::Task.new

  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  task build: %i[bundle:audit rubocop test]
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

task default: :build
