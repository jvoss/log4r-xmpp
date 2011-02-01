require "log4r"
require "log4r-xmpp"

context "XMPP Outputter" do

  before(:all) do

    options = { :buffsize => 10,
                :username   => 'log4r@localhost',
                :password   => '',
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
