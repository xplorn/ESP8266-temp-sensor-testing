gpio2 = 4
gpio4 = 1
gpio5 = 2
sda = gpio5
scl = gpio4
tempF = 0
tempC = 0
p = 0
t_dht = 0
h_dht = 0


function ReadBMP()
    bmp085 = require("bmp085")
    bmp085.init(sda, scl)
    t = bmp085.getUT(true)
    p = bmp085.getUP(true)
    tempF = (t*9/50+32)
    print("Temp BMP180: "..tempF.." deg F")
    print("Pres BMP180: "..p.."hPa")
    print(" ")
    bmp085 = nil
    package.loaded["bmp085"]=nil
end

function ReadDHT()
    dht22 = require("dht22_min")
    dht22.read(gpio2)
    t_dht = dht22.getTemperature()
    h_dht = dht22.getHumidity()
    if h_dht == nil then
        print("Error reading from DHT22")
    else
        t_dhtF = (9 * t_dht / 50 + 32)
        t_dhtF_dec = (9 * t_dht / 5 % 10)
        print("Temp DHT22: "..t_dhtF.."."..t_dhtF_dec.." deg F")
        h_dhtpct = ((h_dht - (h_dht % 10)) / 10)
        print("Humi DHT22: "..h_dhtpct.."%")
        print(" ")
    end
    dht22 = nil
    package.loaded["dht22_min"]=nil
end


ReadBMP()
tmr.alarm(1,5000,1, function()ReadBMP() end)
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
        conn:send("    <p>Temperature: "..tempF.."</p>\n")
        conn:send("    <p>Pressure: "..p.."</p>\n")
        conn:send("  </body>\n")
        conn:send("</html>")
    conn:close()
    end)
end)
