require "bundler/gem_tasks"

default_tasks = []

require "rspec/core/rake_task"
default_tasks  << RSpec::Core::RakeTask.new(:spec)

task default: default_tasks.map(&:name)
