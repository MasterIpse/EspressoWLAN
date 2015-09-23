PIN_BUTTON = 1 -- GPIO5
TIME_ALARM = 25 -- 0.025 second, 40 Hz
gpio.mode(PIN_BUTTON, gpio.INPUT, gpio.PULLUP)
button_state = 1
button_time = 0

function buttonHandler()
 button_state_new = gpio.read(PIN_BUTTON)
 if button_state == 1 and button_state_new == 0 then
 button_time = tmr.time()
 print("BUTTON PRESSED")
 elseif button_state == 0 and button_state_new == 1 then
 button_time_new = tmr.time()
 if tmr.time() > (button_time + 2) then
 tmr.stop(1)
 print("BUTTON DISABLED")
 end
 end
 button_state = button_state_new
end

tmr.alarm(1, TIME_ALARM, 1, buttonHandler)