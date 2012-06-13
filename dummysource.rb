
class SensorSource
    
    # known message types
    HOR  = "h"
    VERT = "v"
    B1   = "q"
    B2   = "a" 
    B3   = "p"
    B4   = "l"
    
    def initialize(port, baudrate)
        # dummy file reader.
        @file = File.new("sensordump.txt", "r")

        # start periodic timer that reads the events periodically
        @ptimer = EventMachine::PeriodicTimer.new(1.0/60.0) {
            line = @file.gets
            
            if line != nil
                parse_sensor_data(line) 
            else
                @file.rewind
                line = @file.gets
            end
        }
    end

    def parse_sensor_data(message)
        messagetypes = ["h ", "v ", "q ", "a ", "p ", "l "];
        if !messagetypes.include?(message[0..1])
            puts "invalid message format: '#{message}'"  
            return
        end

        # extact the first 
        msgtype = message[0..0]
        msgvalue = message[2..message.size].to_i

        @callbackhandler.handle_sensor_event(msgtype, msgvalue)
    end

    def register_event_handler(obj)
        @callbackhandler = obj # if obj.respond_to?("handle_sensor_event")
    end
end


