begin

  require 'jeweler'

  Jeweler::Tasks.new do |s|

    s.name          = 'log4r-xmpp'
    s.summary       = 'XMPP Outputter for Log4r'
    s.email         = 'jvoss@onvox.net'
    s.homepage      = 'http://github.com/jvoss/log4r-xmpp'
    s.description   = 'Add XMPP/Jabber functionality to Log4r'
    s.authors       = ['Jonathan P. Voss']
    s.files         =  FileList['[A-Z]*', '{lib,spec,test}/**/*', '.gitignore']

    s.add_dependency 'log4r'
    s.add_dependency 'xmpp4r'

    s.add_development_dependency 'rake'
    s.add_development_dependency 'rspec'

  end # Jeweler::Tasks.new do |s|

rescue LoadError

  puts 'Jeweler, or one of its dependencies, is not available.'
  puts 'Install it with: gem install technicalpickles-jeweler -s http://gems.github.com'

end # begin
