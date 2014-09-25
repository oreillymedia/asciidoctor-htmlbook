namespace :spec do

  desc 'Run all the tests'
  task :default do
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:spec)
  end

end

task :spec => 'spec:default'
