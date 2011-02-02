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
require "log4r"
require "log4r-xmpp"

describe "XMPP Outputter" do

  before(:all) do

    @options = { :buffsize   => 10,
                 :username   => 'log4r@localhost',
                 :password   => 'secret',
                 :resource   => 'Log4r',
                 :recipients => 'testuser@localhost'
               }

    outputter = Log4r::XMPPOutputter.new('xmpp', @options)

    @log = Log4r::Logger.new 'testlog'
    @log.outputters = outputter

  end # before(:all)

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

    it "should send messages when the buffer is full" do

      outputter = double(@log.outputters.first)
      jabber    = double(@log.outputters.first.instance_variable_get(:@client))

      outputter.should_receive(:debug).exactly(@options[:buffsize]).times
      outputter.should_receive(:flush)

      jabber.should_receive(:send).exactly(1).times

      @options[:buffsize].times { @log.debug "Test message" }

    end # it "should send messages"

    it "should clear the buffer after being sent"

  end # describe "Logging events"

end # describe "XMPP Outputter"
