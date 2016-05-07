print('\nHuzzah ESP8266 Started')

wifi.sta.setip({ip="192.168.9.205",netmask="255.255.255.0",gateway="192.168.9.1"})
wifi.setmode(wifi.STATION)
wifi.sta.config("Monitor2","testing123")

print(wifi.sta.getip())

function startup()
--    dofile('temptest.lua')
    dofile('i2cscan.lua')
    end

print("\n2 second startup delay")
print("======================")
tmr.alarm(0,2000,0,startup)

