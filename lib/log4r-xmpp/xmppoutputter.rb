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

require 'log4r'
require 'xmpp4r/client'

module Log4r

  class XMPPOutputter < Outputter

    attr_reader :username, :password, :resource, :recipients

    def initialize(_name, hash={})

      super(_name, hash)
      _validate(hash)

      @buff = []

      begin
        connect
        Logger.log_internal { "XMPPOutputter '#{@name}' connected as #{@username}"}
      rescue => e
        Logger.log_internal(-2){
          "XMPPOutputter '#{@name}' failed to connect to XMPP server!"
        }
      end # begin
      
    end # def initialize

    # Connects to the Jabber/XMPP server as a client. This is done automatically
    # during initialization.
    #
    def connect

      jid = Jabber::JID::new("#{@username}/#{@resource}")

      @client = Jabber::Client::new(jid)
      @client.connect
      @client.auth(@password)

    end # def connect

    # Immediately sends any messages in the buffer
    #
    def flush

      synch {

        messages = []
        @buff.each{|event| messages.push(format(event))}
        write(messages.to_s)

      }

      @buff.clear

      Logger.log_internal {"Flushed XMPPOutputter '#{@name}"}

    end # def flush

    private

    def canonical_log(event)

      synch {

        @buff.push event if @buff.size <= @buffsize

        flush if @buff.size == @buffsize # TODO a better way to clear the buffer?

      }

    end # def canonical_log

    def write(data)

      @recipients.each do |recipient|

        to   = recipient
        body = data

        message = Jabber::Message.new(to, body).set_type(:normal).set_id('1')

        @client.send message

      end # @recipients.each

    end # def write

    def _validate(hash)

      @buffsize = (hash[:buffsize] or hash['buffsize'] or 1).to_i

      @username = hash[:username] or raise ArgumentError, "Username required"
      @password = hash[:password] or raise ArgumentError, "Password required"
      @resource = hash[:resource] ||= 'Log4r'

      @recipients = hash[:recipients] or raise ArgumentError, "Recipients required"

    end # def _validate

  end # clss XmppOutputter

end # module Log4r
