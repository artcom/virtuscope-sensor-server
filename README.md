Ruby Sensor Server
==================

The Ruby Sensor Server is a web service that enables developers to access the user interface data of the VirtuScope via Server Sent Events. Values (so far) are:

* horizontal rotary encoder value
* vertical rotary encoder value
* all four buttons
* IO-board temperature

To run the Server you need the following programs and packages and what comes along with it.

`ruby 1.8.7

gems:
eventmachine (0.12.10)
ruby-serialport (0.7.0)
sinatra (1.3.2) - git head version recommended, because there is a bug in 1.3.2 [[https://github.com/sinatra/sinatra/issues/446]]
thin (1.3.1)`

Run the server
=============

Go into the directory where you checked out the code and execute the following commandline to start the server. You can add the commandline argument "dummy" to use dummy data, which is useful to develop and test the server on a machine without serialport or IO-Board attached. The "dummy" dummy version replays the data from "sensordump.txt".

`$ ruby bin/sensorserver.rb [dummy]`

Watching Status and Demo Page
=============================

Go into a browser and open http://<hostname/ip>:4567 to view the status page. This can be done from any device which is in the network as the VirtuScope. You should then see a page which looks a lot like this:

To start the status page on the VirtuScope you have to do the following in a terminal:

Using the Eventstream
=====================

The server provides an event stream which can be used by the EventSource Object in any html5 capable web browser.

`// this function is executed if the page has been loaded - (uses jQuery)
$(document).ready(function() {
        // create event source for virtuscope events
        var eventsource = new EventSource("/event_stream");

        // connect event listeners for the buttons and orientation
        eventsource.addEventListener('h', function(msg) { 
            // output rotary encoder data to javascript console.
            console.log("horizontal angle: " + msg.data); 
            }); 
        };
 `

Available events are:
* "h" - horizontal rotary encoder value
* "v" - vertical rotary encoder value
* "q" and "a" - left buttons front and back
* "p" and "l" - right buttons front and back
* "t" - IO Board temperature, divide by 100 to get degrees (celsius)

The rotary encoders have a resolution of 12bit, i.e. 360° are split into 4096 steps. 

Conversion to degrees:
`
function toDeg(value) {
    return (Number(x)/4096) * 360;
}
`

Conversion to radians:
`
function toDeg(value) {
    return (Number(x)/4096) * 2 * Math.PI;
}
`

Other datasources
=================

In addition to the event streams the server send provides xml and json output. 
Here comes the json:
`
# http://localhost:4567/sensors.json
{ 
    "horizontal" : 1345, 
        "vertical" : 52, 
        "button1" : 0, 
        "button2" : 1, 
        "button3" : 0, 
        "button4" : 0, 
        "temperature" : 3827
}
`

Here come the xml:
`
# http://localhost:4567/sensors.xml
<sensors>
<sensor id="h" name="horizontal">1345</sensor>
<sensor id="v" name="vertical">52</sensor>
<sensor id="q" name="button1">0</sensor>
<sensor id="a" name="button2">1</sensor>
<sensor id="p" name="button3">0</sensor>
<sensor id="l" name="button4">0</sensor>
<sensor id="t" name="temperature">3827</sensor>
</sensors>
`



