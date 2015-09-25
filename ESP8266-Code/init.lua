print("2 sec until execution.")
tmr.alarm( 1 , 30000 , 0 , function()end)


-- Constants
SSID    = "WeAll_2.4G"
APPWD   = "W3LC0M3T0W3ALL"
CMDFILE = "WlanSteckdose2.lc"   -- File that is executed after connection

-- Some control variables
wifiTrys     = 0      -- Counter of trys to connect to wifi
NUMWIFITRYS  = 200    -- Maximum number of WIFI Testings while waiting for connection

-- Change the code of this function that it calls your code.
function launch()
  print("Launch!")
  print("Connected to WIFI!")
  print("IP Address: " .. wifi.sta.getip())
  dofile(CMDFILE)
end

function checkWIFI() 
  if ( wifiTrys > NUMWIFITRYS ) then
    print("Sorry. Not able to connect")
  else
    ipAddr = wifi.sta.getip()
    if ( ( ipAddr ~= nil ) and  ( ipAddr ~= "0.0.0.0" ) )then
      -- lauch()        -- Cannot call directly the function from here the timer... NodeMcu crashes...
      tmr.alarm( 1 , 500 , 0 , launch )
    else
      -- Reset alarm again
      tmr.alarm( 0 , 2500 , 0 , checkWIFI)
      print("Checking WIFI..." .. wifiTrys)
      wifiTrys = wifiTrys + 1
    end 
  end 
end

print("-- Starting up! ")

-- Lets see if we are already connected by getting the IP

ipAddr = wifi.sta.getip()
if ( ( ipAddr == nil ) or  ( ipAddr == "0.0.0.0" ) ) then
  -- We aren't connected, so let's connect
  print("Configuring WIFI....")
  wifi.setmode( wifi.STATION )
  wifi.sta.config( SSID , APPWD)
  wifi.sta.autoconnect(1)
  print("Waiting for connection")
  tmr.alarm( 0 , 2500 , 0 , checkWIFI )  -- Call checkWIFI 2.5S in the future.
else
 -- We are connected, so just run the launch code.
 tmr.stop(0)
 launch()
end
-- Drop through here to let NodeMcu run
