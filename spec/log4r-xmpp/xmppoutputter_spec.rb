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

require "log4r"
require "log4r-xmpp"

context "XMPP Outputter" do

  before(:all) do

    options = { :buffsize => 10,
                :username   => 'log4r@localhost',
                :password   => 'secret',
                :resource   => 'Log4r',
                :recipients => 'testuser@localhost'
              }

    outputter = Log4r::XMPPOutputter.new('xmpp', options)

    @log = Log4r::Logger.new 'testlog'
    @log.outputters = outputter

  end # before(:all)

  describe "Logging events" do

    it "should send messages" do

      message = "This is a message with level DEBUG"

      response = @log.debug message
      buff = response[0].instance_variable_get(:@buff)

      buff.class.should == Array
      buff[0].data.should == message

    end # it "should send messages"

  end # describe "Logging events"

end # context "XMPP Outputter"
