
require 'serialport'

class SensorSource
    
    def initialize(port, baudrate)
        # # dummy file reader.
        @serialport = SerialPort.new port, baudrate 

        # list of valid message types
        @messagetypes = ["h ", "v ", "q ", "a ", "p ", "l "];
    
        puts @serialport.read_nonblock(7)

        # start periodic timer that reads the events periodically
        # @ptimer = EventMachine::PeriodicTimer.new(1.0/60.0) {
        #     message = @serialport.read() 
        #     puts "message: #{message}"
        #     if message != "" 
        #         parse_sensor_data(message) 
        #     end 
        # }
    end

    def parse_sensor_data(message_string)
        # message_array = message_string.split("\r\n")
        # 
        # message_array.each do |message|
        #     if !@messagetypes.include?(message[0..1]) 
        #         puts "invalid message format: '#{message}'"  
        #         return
        #     end
        #     
        #     # extact the message type 
        #     msgtype = message[0..0]
        #     
        #     # extract message value
        #     msgvalue = message[2..message.size].to_i
    
        #     # call callbackhandler to dispatch the messages
        #     @callbackhandler.handle_sensor_event(msgtype, msgvalue)
        # end
    end

    def register_event_handler(obj)
        @callbackhandler = obj # if obj.respond_to?("handle_sensor_event")
    end  
end


