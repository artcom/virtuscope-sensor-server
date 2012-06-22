# VirtuScope.rb
# gems
require 'rubygems'
require 'sinatra/base'
require 'eventmachine'
require 'logger'

$eventmachine_library = :pure_ruby # need to force pure ruby

# local includes
if ARGV.include?("dummy")
    puts "using dummysource"
    require 'dummysource.rb'
else
    puts "using sensorsource"
    require 'sensorsource.rb'
end

class VirtuScope < Sinatra::Base

    # configurations 
    configure do
        mime_type :event_stream, 'text/event-stream'
        
        Dir.mkdir('logs') unless File.exist?('logs')
    
        $logger = Logger.new('logs/common.log', 'daily')
    end
   
    # initialize class
    def initialize()
        # initialize base class
        super

        $logger.info("");$logger.info("")
        $logger.info(">> --------------------------------------")
        $logger.info(">> Initializing VirtuScope Sensor Server.")

        # initialize dummy serial source
        # TODO: Read from some configuration file or whatever.
        serialDevice = "/dev/ttyACM1"
        serialBaud = 9600
    
        $logger.info(">> Starting SensorSource")
        @sensorsource = SensorSource.new(serialDevice, serialBaud)
        @sensorsource.register_event_handler(self)     
        
        @event_connections = [] 
        @last_values = {"h"=>0,"v"=>0,
             "a"=>0,"q"=>0,
             "l"=>0,"p"=>0,
             "t"=>0 } 
    end

    def handle_sensor_event(eventtype, eventvalue)
        @last_values[eventtype] = eventvalue
        @event_connections.each do |out_stream|
            out_stream << "event: #{eventtype}\ndata: #{eventvalue} \n\n"
        end
    end

    # define routes
    get '/event_stream' do
        # specify event type 
        content_type :event_stream
        
        stream(:keep_open) do |out|
            #send initial packet without content
            out << "event: connect\n data: \n\n"
            $logger.info("new connection registered. active connections: #{@event_connections.length}")

            # set error callback to remove invalid connections
            out.callback { 
                $logger.info("removing old connection");
                @event_connections.delete(out) 
            }

            # append new connection to list
            @event_connections.push(out)

            # reconnect hack. 
            EventMachine::PeriodicTimer.new(20) { out << "event: ping\n data: \n\n" }
        end
    end

    get '/sensors.*' do |format|
        
        substitutes = {:horizontal => @last_values["h"], :vertical => @last_values["v"], 
            :button1 => @last_values["q"], :button2 => @last_values["a"], 
            :button3 => @last_values["p"], :button4 => @last_values["l"], 
            :temperature => @last_values["t"] 
        }
        
        if format == "json":
            erb :sensors_json, :locals => substitutes        
        elsif format == "xml":
            erb :sensors_xml, :locals => substitutes        
        else 
            404
        end
    end

    get '/' do
        # display the status page. page template is located here: "views/index.erb"
        erb :index
    end
 
    error 404 do
        "Page not found."
    end

    # run the application
    run! if app_file == $0
end

