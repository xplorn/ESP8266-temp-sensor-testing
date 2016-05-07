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
hDHT22pct = 0
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

function ReadBMP()
    bmp085 = require("bmp085")
    bmp085.init(sda, scl)
    tBMP180 = bmp085.getUT(true)
    pBMP180 = bmp085.getUP(true)
    BMP180tempF = (tBMP180*9/50+32)
    print("BMP180 Temperature: "..BMP180tempF.." deg F")
    print("BMP180 Pressure: "..pBMP180.."hPa")
    print(" ")
    bmp085 = nil
    package.loaded["bmp085"]=nil
end

function ReadDHT()
    dht22 = require("dht22_min")
    dht22.read(gpio2)
    tDHT22 = dht22.getTemperature()
    hDHT22 = dht22.getHumidity()
    if hDHT22 == nil then
        print("DHT22: No Reading")
        print(" ")
    else
        tDHT22F = (9 * tDHT22 / 50 + 32)
        tDHT22F_dec = (9 * tDHT22 / 5 % 10)
        print("DHT22 Temperature: "..tDHT22F.."."..tDHT22F_dec.." deg F")
        hDHT22pct = ((hDHT22 - (hDHT22 % 10)) / 10)
        print("DHT22 Humidity: "..hDHT22pct.."%")
        print(" ")
    end
    dht22 = nil
    package.loaded["dht22_min"]=nil
end


ReadBMP()
tmr.alarm(1,5000,1, function()ReadBMP() end)
tmr.alarm(3,5000,1, function()ReadDs18b20() end)
tmr.alarm(2,5000,1, function()ReadDHT() end)


srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(conn,payload)
    conn:send("HTTP/1.1 200 OK\r\n")
    conn:send("Content-type: html\r\n\r\n")
    -- print(payload) -- use for debugging
        conn:send("<html\n")
        conn:send("  <head>\n")
        conn:send("    <title>ESP8266 Web Server</title>\n")
        conn:send("  </head>\n")
        conn:send("  <body>\n")
        conn:send("    <p>BMP180 Temperature (deg F): "..BMP180tempF.."</p>\n")
        conn:send("    <p>BMP180 Pressure (hPa): "..pBMP180.."</p>\n")
        conn:send("    <p>DHT22 Temperature (deg F): "..tDHT22F.."."..tDHT22F_dec.."</p>\n")
        conn:send("    <p>DHT22 Humidity (%): "..hDHT22pct.."</p>\n")
        conn:send("    <p>DS18B20 Temperature (deg F): "..tDS18B20.."</p>\n")
        conn:send("  </body>\n")
        conn:send("</html>")
    conn:close()
    end)
end)
