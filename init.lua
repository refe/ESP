print('init.lua ver 1.2')
--Settings
--- WIFI ---
wifi_SSID = "xxxx" -- ssid
wifi_password = "xxxxx" -- ssid password
-- wifi.PHYMODE_B 802.11b, More range, Low Transfer rate, More current draw
-- wifi.PHYMODE_G 802.11g, Medium range, Medium transfer rate, Medium current draw
-- wifi.PHYMODE_N 802.11n, Least range, Fast transfer rate, Least current draw 
wifi_signal_mode = wifi.PHYMODE_N
-- If the settings below are filled out then the module connects 
-- using a static ip address which is faster than DHCP and 
-- better for battery life. Blank "" will use DHCP.
-- My own tests show around 1-2 seconds with static ip
-- and 4+ seconds for DHCP
client_ip="192.x.x.x" -- for static ip, faster connection
client_netmask="255.255.255.0"
client_gateway="192.x.x.x" -- gateway

-- Connect to the wifi network
wifi.setmode(wifi.STATION) 
wifi.setphymode(wifi_signal_mode)
wifi.sta.config(wifi_SSID, wifi_password)
wifi.sta.connect()
if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
end

print('set mode=STATION (mode='..wifi.getmode()..')')
print('MAC: ',wifi.sta.getmac())
print('chip: ',node.chipid())
print('heap: ',node.heap())
 tmr.alarm(1, 1000, 1, function()
  if wifi.sta.getip()== nil then
  print("IP unavaiable, Waiting...")
 else
  tmr.stop(1)
 print("ESP8266 mode is: " .. wifi.getmode())
 print("The module MAC address is: " .. wifi.ap.getmac())
 print("Config done, IP is "..wifi.sta.getip())
 dofile ("thing.lua")
 end
end)
