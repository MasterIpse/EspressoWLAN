--wifi.setmode(wifi.STATION)
--wifi.sta.config("We All","W3LC0M3T0W3ALL")

-- print(wifi.sta.getip())
-- wifi.sta.autoconnect(1)

print("Lass die Faulheit beginnen!")
pwm.setup(6, 100, 1000)
pwm.start(6)
pwm.stop(6)
pwm.setup(7, 100, 0)
pwm.start(7)
pwm.stop(7)
pwm.setup(5, 100, 300)
pwm.start(5)
pwm.stop(5)

-- Button setup
PIN_BUTTON = 1 -- GPIO5
TIME_ALARM = 150 
gpio.mode(PIN_BUTTON, gpio.INPUT, gpio.PULLUP)
button_status = "off"
button_state = 0

-- Button Funktion
function buttonHandler()
    button_state_new = gpio.read(PIN_BUTTON)
    if (button_state == 0 and button_state_new == 0) then
        print("Button on")
        print("Button State: "..button_state)
        print("Button State new: "..button_state_new)
        on()
    elseif (button_state == 1 and button_state_new == 0) then
        print("Button off")
        off()
    end
    -- button_state = button_state_new
end

tmr.alarm(6, TIME_ALARM, 1, buttonHandler)

-- Relay PIN 2 an GPIO4
gpio.mode(2, gpio.OUTPUT)

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
            buf = buf.."<p>Espresso-Maschine <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
                local _on,_off = "",""
        if(_GET.pin == "ON1")then
            on()
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
    print("Betrieb")
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
    print("Bald aus")
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
    print("off end")
end

function on()
  button_state = 1
  button_status = "on"
  gpio.write(2, gpio.HIGH)
    orange()
    print("Aufwärmen")
    tmr.alarm(3, 300000, 0, green)
    tmr.alarm(4, 1080000, 0, red)
    tmr.alarm(5, 1200000, 0, off)
    print("on end")
end