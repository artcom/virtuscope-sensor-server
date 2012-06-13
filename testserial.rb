require 'rubygems'
require 'serialport'

sp = SerialPort.new "/dev/ttyACM1", 9600

10.times do
    line = sp.read_nonblock
    lines = line.split("\r\n")
   
    puts "bla"
    lines.each do |foo|
        puts foo
    end 
    sleep 0.01
end

puts "mach's gut, Welt!"
