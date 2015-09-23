wifi.setmode(wifi.STATION)
wifi.sta.config("We All","W3LC0M3T0W3ALL")
print(wifi.sta.getip())
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
        buf = buf.."<h1> ESP8266 Web Server</h1>";
        buf = buf.."<p>Espresso-Maschine <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
                local _on,_off = "",""
        if(_GET.pin == "ON1")then
            orange()
			tmr.alarm(0, 2500, 0, green)
			tmr.alarm(1, 5000, 0, red)
			tmr.alarm(2, 6000, 0, off)
        elseif(_GET.pin == "OFF1")then
              off()
        end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)

function orange()
	pwm.setup(6, 100, 1000)
	pwm.start(6)
	pwm.setup(7, 100, 0)
	pwm.start(7)
	pwm.setup(5, 100, 300)
	pwm.start(5)
end

function green()
	pwm.stop(6)
	pwm.stop(7)
	pwm.setup(5, 100, 500)
	pwm.start(5)
end

function red()
	pwm.stop(5)
	pwm.stop(7)
	pwm.setup(6, 100, 500)
	pwm.start(6)
end

function off()
	pwm.stop(5)
	pwm.stop(7)
	pwm.stop(6)
end
	
	