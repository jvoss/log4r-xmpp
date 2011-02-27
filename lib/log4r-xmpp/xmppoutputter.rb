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

    # XMPPOutputter is initialized the same as other Log4r Outputters with the
    # addition of the following hash options:
    #
    #   :buffsize   => The number of logging events to buffer before sending (default 1)
    #   :username   => Sending user's XMPP/Jabber account username
    #   :password   => Sending user's XMPP/Jabber account password
    #   :resource   => Optional sending user's XMPP/Jabber resource (default 'Log4r')
    #   :recipients => Array of usernames to send Log4r log statements to
    #
    # Example:
    #
    #   options => { :buffsize   => 10,
    #                :username   => 'log4r@example.com',
    #                :password   => 'secret',
    #                :resource   => 'Log4r',
    #                :recipients => ['recipient1@example.com', 'recipient2@example.com']
    #              }
    #
    #   outputter = Log4r::XMPPOutputter.new('xmpp', options)
    #
    #   mylog = Log4r::Logger.new 'mylog'
    #   mylog.outputters = outputter
    #
    #   mylog.debug "This is a test message sent at level DEBUG"
    #
    def initialize(_name, hash={})

      super(_name, hash)

      @buff = []

      begin

        connect
        Logger.log_internal { "XMPPOutputter '#{@name}' connected as #{@username}"}

      rescue => e

        xmpp_error = "#{e.class}: #{e.message}"

        Logger.log_internal(-2) do

          "XMPPOutputter '#{@name}' failed to connect to XMPP server: #{xmpp_error}"

        end # Logger.log_internal

      end # begin
      
    end # def initialize

    # Connects to the Jabber/XMPP server as a client. This is done automatically
    # during initialization.
    #
    def connect

      Jabber::logger = Log4r::Logger['xmpp4r'].nil? ? Log4r::Logger.new('xmpp4r')\
                                                    : Log4r::Logger['xmpp4r']

      # Enable XMPP4r library to log DEBUG events to the internal logger
      #
      Jabber::warnings = true

      jid = Jabber::JID::new("#{@username}/#{@resource}")

      @client = Jabber::Client::new(jid)
      @client.connect
      @client.auth(@password)

    end # def connect

    # Call to force an outputter to write any buffered log events.
    #
    def flush

      synch do

        messages = []

        @buff.each{ |event| messages.push( format(event) ) }

        write(messages)

      end # synch

      @buff.clear

      Logger.log_internal { "Flushed XMPPOutputter '#{@name}'" }

    end # def flush

    protected

    # Validates the common hash arguments as required by Log4r then sets up the XMPP options
    # for the outputter.
    #
    def validate_hash(hash)

      super(hash)

      # Convert hash keys to symbols if provided as strings (as if configured by YAML)
      hash = hash.inject({}){|temp,(k,v)| temp[k.to_sym] = v; temp}

      @buffsize = hash[:buffsize].to_i ||= 1

      @username = hash[:username]      or raise ArgumentError, "Username required"
      @password = hash[:password]      or raise ArgumentError, "Password required"
      @resource = hash[:resource]      ||= 'Log4r'

      @recipients = hash[:recipients]  or raise ArgumentError, "Recipients required"

    end # def validate_hash

    private

    # This method handles all log events passed to this Outputter.
    #
    def canonical_log(event)

      synch do

        @buff.push event if @buff.size <= @buffsize

        flush if @buff.size >= @buffsize

      end # synch

    end # def canonical_log

    # Method to actually write the formatted data to XMPP.
    #
    def write(data)

      body = ''

      data.kind_of?(Array) ? data.each{|x| body << x} : body = data
      
      [@recipients].flatten.each do |recipient|

        to = recipient

        message = Jabber::Message.new(to, body).set_type(:normal).set_id('1')

        begin

          @client.send message

        rescue => e

          xmpp_error = "#{e.class}: #{e.message}"

          Logger.log_internal(-2) do

            "XMPPOutputter '#{@name}' failed to send message: #{xmpp_error}"

          end # Logger.log_internal

        end # begin

      end # @recipients.each

    end # def write

  end # class XMPPOutputter

end # module Log4r
