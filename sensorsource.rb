
require 'serialport'

class SensorSource
    
    def initialize(port, baudrate)
        @serialport = SerialPort.new port, baudrate 

        # start periodic timer that reads the events periodically
        @ptimer = EventMachine::PeriodicTimer.new(1.0/60.0) {
            parse_sensor_data()
        }
    end

    # parse messages of the following format: "[h,v,q,a,p,l,t] [-][0-9]\r\n"
    # example: "h -349\r\n" - horizontal  rotary encoder value of -349
    # read until 100 pakets are processed or EOF is reached.
    # after processing a packet successfully the send callback is invoked.
    def parse_sensor_data
        
        begin
            handled_messages = 0
            msg = ""

            while handled_messages < 100 do
            
                # output values
                messagetype = ""
                valuestring = ""

                msg = @serialport.read_nonblock(1)
                # search for valid start symbol, i.e. one of [h,v,q,a,p,l]
                if /[^hvqaplt]/.match(msg)
                    # restart parsing process until a valid symbol is found
                    puts "no valid messagetype found. got: #{msg}"
                    next
                end
                
                # assign messagetype
                messagetype = msg

                msg = @serialport.read_nonblock(1)
                # search for " "
                if /[^ ]/.match(msg)
                    puts "space missing after first byte. got: #{msg}"
                    next
                end
            ###
                msg = @serialport.read_nonblock(1)
                # search for a number or a "-"
                if /[^0-9|-]/.match(msg)
                    
                    next
                end
                 
                valuestring = valuestring + msg
            ###     
                # only allow 4 digit values to avoid infinite loop here.
                4.times do 
                    msg = @serialport.read_nonblock(1)
                        
                    # search for a number or "\n"
                    if /[0-9]/.match(msg)
                        valuestring = valuestring + msg
                    else 
                        break 
                    end
                end
            ###     
            
                # flush trailing "\n" and "\r"
                msg = @serialport.read_nonblock(1)
                
                # message parsing successful, invoke callback
                @callbackhandler.handle_sensor_event(messagetype, valuestring)

                handled_messages = handled_messages + 1
            end
        rescue EOFError
            Finished processing the file
        rescue Exception => e
            # puts "hm, what the hell.."
            # puts e
        end
    end

    def register_event_handler(obj)
        @callbackhandler = obj # if obj.respond_to?("handle_sensor_event")
    end  
end


