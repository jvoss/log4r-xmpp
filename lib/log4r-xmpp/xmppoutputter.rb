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

      synch { @buff.each{|event| write(format(event))} }
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

      @username = hash[:username]
      @password = hash[:password]
      @resource = hash[:resource]

      @recipients = hash[:recipients]

    end # def _validate

  end # clss XmppOutputter

end # module Log4r
