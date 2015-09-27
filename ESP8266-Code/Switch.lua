-- Variable to display the current state
status = "off"

print("Switch start")

-- Turn the LED off.
pwm.setup(6, 100, 1000)
pwm.start(6)
pwm.stop(6)
pwm.setup(7, 100, 0)
pwm.start(7)
pwm.stop(7)
pwm.setup(5, 100, 300)
pwm.start(5)
pwm.stop(5)

-- Setup the Button
PIN_BUTTON = 1 -- GPIO5
TIME_ALARM = 150  -- Frequency of polling
gpio.mode(PIN_BUTTON, gpio.INPUT, gpio.PULLUP)
button_status = "off"
button_state = 0

-- Button function
-- unless pushed button_state_new is 1
function buttonHandler()
    button_state_new = gpio.read(PIN_BUTTON)
	-- If Button is pressed and hasen't been pressed before, call on(), else call off
    if (button_state == 0 and button_state_new == 0) then
      	print("Button on")
      	on()
    elseif (button_state == 1 and button_state_new == 0) then
        print("Button off")
        off()
    end
end

tmr.alarm(6, TIME_ALARM, 1, buttonHandler)

-- WLAN is checked every 100000 ms
function connected()
	print("Verbindung wird überprüft")
	ipAddr = wifi.sta.getip()
	if ( ( ipAddr == nil ) or  ( ipAddr == "0.0.0.0" ) ) then
		-- We aren't connected, so let's connect
		print("Verbindung wird wiederhergestellt")
		wifi.setmode( wifi.STATION )
		wifi.sta.config( SSID , APPWD)
		wifi.sta.autoconnect(1)
	else
		print("Verbindung stabil")
	end
end

tmr.alarm(2, 100000, 1, connected)
		

		-- Setup PIN 2 an for Relay on GPIO4
gpio.mode(2, gpio.OUTPUT)


-- HTTP-Stuff
srv = net.createServer (net.TCP, 30)

srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<h1> Café Faultier</h1>";
			buf = buf.."<p>Status: "..status.."</p><br>";
            buf = buf.."<p>Espresso-Maschine <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
                local _on,_off = "",""
        if(_GET.pin == "ON1")then
	        -- Send Pushbullet Notification. Only if switched on via HTTP
	        conn=net.createConnection(net.TCP, 0) 
	    	conn:on("receive", function(conn, payload) print(payload) end )
	    	conn:connect(80,"192.168.2.4")
	    	conn:send("GET /iot/pushit.php?title=Espresso&msg=Maschine%20ist%20an HTTP/1.1\r\nHost: 192.168.2.4\r\nConnection: close\r\nAccept: */*\r\n\r\n")
	       	on()
        elseif(_GET.pin == "OFF1")then
            off()
        end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)

-- Create the color orange with PWM
function orange()
	print("Aufwärmen")
	status = "Aufwärmen"
    pwm.setup(6, 100, 1000)
    pwm.start(6)
    pwm.setup(7, 100, 0)
    pwm.start(7)
    pwm.setup(5, 100, 300)
    pwm.start(5)
end

-- Create the color red with PWM
function green()
	-- Send Pushbullet Notification
	conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) print(payload) end )
    conn:connect(80,"192.168.2.4")
    conn:send("GET /iot/pushit.php?title=Espresso&msg=Maschine%20ist%20aufgewaermt HTTP/1.1\r\nHost: 192.168.2.4\r\nConnection: close\r\nAccept: */*\r\n\r\n")
    print("Betrieb")
    status = "Betrieb"
    pwm.stop(6)
    pwm.stop(7)
    pwm.setup(5, 100, 500)
    pwm.start(5)
end

-- Create the color red with PWM
function red()
	print("Bald aus")
	status = "Bald aus"
    pwm.stop(5)
    pwm.stop(7)
    pwm.setup(6, 100, 500)
    pwm.start(6)
end

-- Turn off relay and LEDs, set button_count to 0
function off()
    button_state = 0
    button_status = "off"
    gpio.write(2, gpio.LOW)
    pwm.stop(5)
    pwm.stop(7)
    pwm.stop(6)
    tmr.stop(3)
    tmr.stop(4)
    tmr.stop(5)
    button_count = 0
	status = "off"
    print("off end")
end


-- Turn on relay, LEDs and Timer. Set button_state = 1
function on()
	button_state = 1
	button_status = "on"
	gpio.write(2, gpio.HIGH)
    orange()
    tmr.alarm(3, 300000, 0, green)
    tmr.alarm(4, 1080000, 0, red)
    tmr.alarm(5, 1200000, 0, off)
	status = "on"
    print("on end")
end
