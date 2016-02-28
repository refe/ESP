-- https://github.com/refe/ESP-03-thingspeak
WRITEKEY="xxxxxxxxxxxx"    -- set your thingspeak.com key
   tmr.delay(100000)
function ReadInVdd()
    invddmv = adc.readvdd33();
    invddv = (invddmv / 1000);
    print("battery voltage: "..(invddv).." V");
    -- return battery voltage in Volts
end
-- send to https://api.thingspeak.com
function sendTS(humi,temp)
conn = nil
conn = net.createConnection(net.TCP, 0)
conn:on("receive", function(conn, payload)success = true print(payload)end)
conn:on("connection",
   function(conn, payload)
   print("Connected")
   conn:send('GET /update?key='..WRITEKEY..
   '&field1='..invddv..
   ' HTTP/1.1\r\n')
   conn:send('Host: api.thingspeak.com\r\n')
   conn:send('Accept: */*\r\n')
   conn:send('User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n\r\n')
end)
conn:connect(80,'api.thingspeak.com')
   conn:on("disconnection", function(conn, payload) print('Disconnected')
        print("Going to deep sleep for "..(300).." seconds") 
        tmr.alarm(1,300000,1,function() ReadInVdd() sendTS(humi,temp)end) --node.dsleep(60000000-tmr.now()) end) 
        end)
end
ReadInVdd()
sendTS(humi,temp)
tmr.alarm(1,300000,1,function() ReadInVdd() sendTS(humi,temp) end)-- node.dsleep(60000000-tmr.now()) end)
