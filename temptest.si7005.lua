gpio4 = 1
gpio5 = 2
sda = gpio5
scl = gpio4
SDA_PIN = 6 -- sda pin, GPIO12
SCL_PIN = 5 -- scl pin, GPIO14

tBMP180 = 0
pBMP180 = 0
tSI7005 = 0
hSI7005 = 0
t = 0
h = 0

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

function ReadSI7005()
    si7005 = require("si7021")
    si7005.init(sda, scl)
    h = si7005.getHumidity()
    t = si7005.getTemperature()
--    tSI7005F = (t*9/50+32)
    print("SI7005 Temperature: "..tSI7005.." deg F")
    print("SI7005 Humidity: "..h.." %")
    print(" ")
    si7005 = nil
    package.loaded["si7021"]=nil
end

ReadBMP()
ReadSI7005()
tmr.alarm(1,5000,1, function()ReadBMP() end)
tmr.alarm(4,5000,1, function()ReadSI7005() end)

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
        conn:send("  </body>\n")
        conn:send("</html>")
    conn:close()
    end)
end)
