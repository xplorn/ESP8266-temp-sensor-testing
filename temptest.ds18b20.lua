gpio0 = 3
gpio2 = 4
gpio4 = 1
gpio5 = 2
sda = gpio5
scl = gpio4

tBMP180 = 0
pBMP180 = 0
tDHT22 = 0
tDHT22F = 0
tDHT22F_dec = 0
hDHT22 = 0
tDS18B20 = 0

function ReadDs18b20()
    t = require("ds18b20")
    t.setup(gpio0)
    addrs = t.addrs()
    tempC=t.read()
    tDS18B20 = (9 * tempC / 5 + 32)
    print("DS18B20 Temperature: "..tDS18B20.." F")
    print(" ")
    t = nil
    ds18b20 = nil
    package.loaded["ds18b20"]=nil
end


tmr.alarm(3,5000,1, function()ReadDs18b20() end)
       

