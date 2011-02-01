require 'rake'
require 'rspec/core/rake_task'

namespace :spec do

  desc "Run specs with RCov"
  RSpec::Core::RakeTask.new(:coverage) do |t|

    t.rcov       = true
    t.rcov_opts  = ['--exclude', '/gems/,/Library/,/usr/,spec', '--html']

  end # Spec::Rake::SpecTask.new

end # namespace :test
