gpio2 = 4

tDHT22 = 0
tDHT22F = 0
tDHT22F_dec = 0
hDHT22 = 0
hDHT22pct = 0

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
        conn:send("    <p>DHT22 Temperature (deg F): "..tDHT22F.."."..tDHT22F_dec.."</p>\n")
        conn:send("    <p>DHT22 Humidity (%): "..hDHT22pct.."</p>\n")
        conn:send("  </body>\n")
        conn:send("</html>")
    conn:close()
    end)
end)
