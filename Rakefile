# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test*.rb']
  t.verbose = true
  t.warning = false
end

require 'bundler/audit/task'
Bundler::Audit::Task.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: %i[bundle:audit rubocop test]
