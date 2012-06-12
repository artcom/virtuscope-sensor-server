# VirtuScope.rb
require 'sinatra/base'
require 'sensorsource.rb'

class VirtuScope < Sinatra::Base

    # configure event stream mimetype
    configure do
        mime_type :event_stream, 'text/event-stream'
    end
   
    # initialize class
    def initialize()
        # initialize base class
        super
    
        # initialize dummy serial source
        @sensorsource = SensorSource.new('/dev/bla', 9600)
        @sensorsource.register_event_handler(self)     
        
        @event_connections = [] 
    end

    def handle_sensor_event(eventtype, eventvalue)
        @event_connections.each do |out_stream|
            out_stream << "event: #{eventtype}\ndata: #{eventvalue} \n\n"
        end
    end

    # define routes
    get '/event_stream' do
        content_type :event_stream
        
        stream(:keep_open) do |out|
            
            @event_connections.push(out)
            out << "event: connect\n data: \n\n"

            # reconnect hack
            EventMachine::PeriodicTimer.new(20) { out << "event: ping\n data: \n\n" }
        end
    end

    get '/' do
        erb :index
    end
  
    # run the application
    run! if app_file == $0
end

