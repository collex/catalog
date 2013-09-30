#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

begin
  require 'rspec/core/rake_task'

  desc "Run the code examples in spec/unit"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/unit/**/*_spec.rb"
  end
rescue LoadError
end

require File.expand_path('../config/application', __FILE__)

load "#{Rails.root}/config/initializers/1_settings.rb"
CollexCatalog::Application.load_tasks
