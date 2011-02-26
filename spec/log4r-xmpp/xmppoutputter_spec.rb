# Copyright 2011 Jonathan P. Voss
#
# This file is part of Log4r-XMPP
#
# Log4r-XMPP is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# Log4r-XMPP is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License
# along with Log4r-XMPP. If not, see <http://www.gnu.org/licenses/>.
#

require "rspec"
require "log4r-xmpp"
require "log4r-xmpp/yamlconfigurator"

describe "XMPP Outputter" do

  before(:each) do

    @options = { :buffsize   => 10,
                 :username   => 'log4r@localhost',
                 :password   => 'secret',
                 :resource   => 'Log4r',
                 :recipients => ['testuser@localhost']
               }

    @outputter = Log4r::XMPPOutputter.new('xmpp', @options)

    @log = Log4r::Logger.new 'testlog'
    @log.outputters = @outputter

  end # before(:all)

  after(:each) do

    @log = nil

  end # after(:each)

  describe "initialization" do

    it "should require a username" do

      options = @options.dup
      options.delete(:username)

      l = lambda { Log4r::XMPPOutputter.new('xmpp', options) }

      l.should raise_error(ArgumentError)

    end # it "should require a username"

    it "should require a password" do

      options = @options.dup
      options.delete(:password)

      l = lambda { Log4r::XMPPOutputter.new('xmpp', options) }

      l.should raise_error(ArgumentError)

    end # it "should require a password"

    it "should require recipients" do

      options = @options.dup
      options.delete(:recipients)

      l = lambda { Log4r::XMPPOutputter.new('xmpp', options) }

      l.should raise_error(ArgumentError)

    end # it "should require recipients"

    it "should not require a buffer size" do

      options = @options.dup
      options.delete(:buffsize)

      l = lambda { Log4r::XMPPOutputter.new('xmpp', options) }

      l.should_not raise_error(ArgumentError)

    end # it "should not require a buffer size"

    it "should not require a resource" do

      options = @options.dup
      options.delete(:resource)

      l = lambda{ Log4r::XMPPOutputter.new('xmpp', options) }

      l.should_not raise_error(ArgumentError)

    end # it "should not require a resource"

  end  # describe "initialization"

  describe "Log4r support" do

    it "should satisfy Log4r::Outputter requirements" do

      # Public Instance Methods
      flush         = :flush
      formatter     = :formatter
      level         = :level
      only_at       = :only_at

      # Protected Instance Methods
      validate_hash = :validate_hash

      # Private Instance Methods
      canonical_log = :canonical_log
      format        = :format
      synch         = :synch
      write         = :write

      # Pre Ruby 1.9, method arrays included strings instead of symbols
      if RUBY_VERSION < '1.9'

        canonical_log = canonical_log.to_s
        flush         = flush.to_s
        format        = format.to_s
        formatter     = formatter.to_s
        level         = level.to_s
        only_at       = only_at.to_s
        synch         = synch.to_s
        validate_hash = validate_hash.to_s
        write         = write.to_s

      end # if RUBY_VERSION

      @outputter.public_methods.include?(flush).should            == true
      @outputter.public_methods.include?(formatter).should        == true
      @outputter.public_methods.include?(level).should            == true
      @outputter.public_methods.include?(only_at).should          == true

      @outputter.protected_methods.include?(validate_hash).should == true

      @outputter.private_methods.include?(canonical_log).should   == true
      @outputter.private_methods.include?(format).should          == true
      @outputter.private_methods.include?(synch).should           == true
      @outputter.private_methods.include?(write).should           == true

    end # it "should satisfy Log4r::Outputter requirements"

    it "should accept strings as keys in the configuration hash" do

      options = { 'buffsize'   => 10,
                  'username'   => 'log4r@localhost',
                  'password'   => 'secret',
                  'resource'   => 'Log4r',
                  'recipients' => ['testuser@localhost']
               }

      outputter = Log4r::XMPPOutputter.new('xmpp', options)

      log = Log4r::Logger.new 'testlog'
      log.outputters = @outputter

      log.outputters[0].username.should   == options['username']
      log.outputters[0].password.should   == options['password']
      log.outputters[0].resource.should   == options['resource']
      log.outputters[0].recipients.should == options['recipients']

    end # it "should accept strings as keys in the configuration hash" do

    it "should satisfy Log4r::YamlConfigurator requirements" do

      path = File.dirname(__FILE__)

      Log4r::YamlConfigurator['RESOURCE'] = 'Log4r-XMPP'
      Log4r::YamlConfigurator['DOMAIN']   = 'localhost'

      Log4r::YamlConfigurator.load_yaml_file("#{path}/log4r-xmpp.yaml")

      log = Log4r::Logger['mylogger']

      log.outputters[0].class.should      == Log4r::XMPPOutputter
      log.outputters[0].username.should   == 'log4r@localhost'
      log.outputters[0].password.should   == 'secret'
      log.outputters[0].resource.should   == 'Log4r-XMPP'
      log.outputters[0].recipients.should == ['user1@localhost', 'user2@localhost']

    end # it "should satisfy Log4r::YamlConfigurator requirements"

  end # describe "Log4r support"

  describe "logging events" do

    it "should buffer messages" do

      message = "This is a message with level DEBUG"

      response = @log.debug message
      buff = response[0].instance_variable_get(:@buff)

      buff.empty?.should_not == true
      buff.class.should == Array
      buff[0].data.should == message

      buff.clear

    end # it "should send messages"

    it "should flush messages when the buffer is full" do

      @outputter.should_receive(:flush)

      @options[:buffsize].times { @log.debug "Test message" }

    end # it "should send messages"

    it "flush should clear the buffer after messages are sent" do

      @options[:buffsize].times { @log.debug "Test message" }

      buffer = @outputter.instance_variable_get(:@buff)

      buffer.empty?.should == true

    end # it "flush should clear the buffer after being sent"

    it "should send messages to Jabber server" do

      jabber = @outputter.instance_variable_get(:@client)

      jabber.should_receive(:send).exactly(1).times

      @options[:buffsize].times { @log.debug "Test message" }

    end # it "should send messages to XMPP server"

  end # describe "logging events"

end # describe "XMPP Outputter"
