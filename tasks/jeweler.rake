begin

  require 'jeweler'
  require './lib/log4r-xmpp/log4r-xmpp.rb'

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
    s.add_development_dependency 'rcov'
    s.add_development_dependency 'rspec'

    s.version = Log4r::XMPPOutputter::VERSION

  end # Jeweler::Tasks.new do |s|

rescue LoadError

  puts 'Jeweler, or one of its dependencies, is not available.'
  puts 'Install it with: gem install jeweler'

end # begin
