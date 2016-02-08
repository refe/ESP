WRITEKEY="xxxxxxxxxxxxxxxxxxx"    -- set your thingspeak.com key
PIN = 7                --  DHT22 data pin, GPIO13
OSS = 2 -- oversampling setting (0-3)
SDA_PIN = 4 -- BMP180 sda pin, GPIO2
SCL_PIN = 5 -- BMP180 scl pin, GPIO14
   tmr.delay(1000000)
   humi=0
   temp=0

-- Load BMP180 and read temperature and presure
function ReadBMP180()
bmp085=require("bmp085")
bmp085.init(SDA_PIN, SCL_PIN)
t = bmp085.temperature()
p = bmp085.pressure(OSS)
mmhg = (p * 75 / 10000)
mbar = (p / 100)

-- temperature in degrees Celsius  and Farenheit
-- formula to covert t(C) in t(F) , or t(K)
--   t(F) = (t(C) * 1.8 + 32)
--   t(K) = (t(C) + 273.15)
print("BMP180 Sensor")
print("Temperature: "..(t/10).." deg C")
print("Temperature: "..(9 * t / 50 + 32).." deg F")

-- pressure in differents units
print("Pressure: "..(p).." Pa")
print("Pressure: "..(p / 100).." hPa")
print("Pressure: "..(p / 100).." mbar")
print("Pressure: "..(p * 75 / 10000).." mmHg")
    
    -- release module
    bmp085=nil
    package.loaded["bmp085"]=nil
--    return t,p,mmhg,mbar
end

--load DHT module and read sensor
function ReadDHT()
    dht=require("dht")
    -- dht.read(PIN)
    status,temp,humi,temp_decimial,humi_decimial = dht.read(PIN)
        if( status == dht.OK ) then
          -- Integer firmware using this example
      --      print(
      --          string.format(
      --              "\r\nDHT22 Sensor\r\nTemperature:%d.%01d\r\nHumidity:%d.%01d\r\n",
      --              temp,
      --              temp_decimial,
      --              humi,
      --              humi_decimial
      --          )
      --      )
            -- Float firmware using this example
           print("Humidity (F):    "..humi.."%")
           print("Temperature (F): "..temp.."C")
        elseif( status == dht.ERROR_CHECKSUM ) then
            print( "DHT Checksum error." );
        elseif( status == dht.ERROR_TIMEOUT ) then
            print( "DHT Time out." );
        end
    -- release module
    dht=nil
    package.loaded["dht"]=nil
end

-- calculate dewPoint using temperature and humidity 
-- provided by DHT22 Sensor
function dewPointFast(celsius, humidity)
--a = 17.271
--b = 237.7
--temp = ((a * celsius) / (b + celsius) + (math.log (humidity*0.01)))
--Td = ((b * temp) / (a - temp))
Td = (celsius - ((100 - humidity)/5))
print("DewPoint Temperature: "..Td.." deg C")
return Td
end

-- calculate HeatIndex using temperature and humidity 
-- provided by DHT22 Sensor
function heatIndex(temp, humi) --(tempF, humidity)
  c1 = -42.38
  c2 = 2.049
  c3 = 10.14
  c4 = -0.2248
  c5 = -6.838e-3
  c6 = -5.482e-2
  c7 = 1.228e-3
  c8 = 8.528e-4
  c9 = -1.99e-6
  T = (temp * 1.8 + 32)-- temp
  R = humi --humi

--  A = ((((c5 * T) + c2) * T) + c1)
--  B = ((((c7 * T) + c4) * T) + c3)
--  C = ((((c9 * T) + c8) * T) + c6)

--  rv = (((C * R + B) * R) + A)
   rv = (c1 + (c2 * T) + (c3 * R) + (c4 * T * R) + (c5 * T * T) + (c6 * R * R) + (c7 * T * T * R) + (c8 * T * R * R) + (c9 * T * T * R * R))
   hi = ((rv  -  32) * (5/9))
   print("Heat Index Temperature: "..hi.." deg C")
return hi
end

-- send to https://api.thingspeak.com
function sendTS(humi,temp)
conn = nil
conn = net.createConnection(net.TCP, 0)
conn:on("receive", function(conn, payload)success = true print(payload)end)
conn:on("connection",
   function(conn, payload)
   print("Connected")
   conn:send('GET /update?key='..WRITEKEY..'&field4='..humi..'&field3='..temp..'&field1='..(t/10)..'&field5='..mmhg..'&field2='..mbar..'&field6='..Td..'&field7='..hi..'HTTP/1.1\r\n\
   Host: api.thingspeak.com\r\nAccept: */*\r\nUser-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n')end)
conn:connect(80,'api.thingspeak.com')
   conn:on("disconnection", function(conn, payload) print('Disconnected')
        print("Going to deep sleep for "..(600).." seconds") 
        tmr.alarm(1,100,0,function() node.dsleep(600000000-tmr.now()) end) 
        end)

end
ReadDHT()
ReadBMP180()
heatIndex(temp, humi)
dewPointFast(temp, humi)
sendTS(humi,temp)
tmr.alarm(1,100000,1,function() ReadDHT() sendTS(humi,temp) node.dsleep(600000000-tmr.now()) end)
