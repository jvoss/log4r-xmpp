require 'rake'
require 'spec/rake/spectask'

namespace :test do

  desc "Run all RSpec examples"
  Spec::Rake::SpecTask.new(:spec) do |t|

    t.spec_files = FileList['spec/**/*.rb']

  end # Spec::Rake::SpecTask.new

end # namespace :test
