Config = {} -- DON'T TOUCH

Config.DrawDistance       = 100.0 -- Change the distance before you can see the marker. Less is better performance.
Config.EnableBlips        = true -- Set to false to disable blips.
Config.MarkerType         = 1
Config.MarkerSize         = { x = 1.5, y = 1.5, z = 1.0 }
Config.MarkerSizeL        = { x = 3.0, y = 3.0, z = 1.0 }
Config.MarkerColor        = { r = 204, g = 50, b = 50 }

Config.Locale             = 'en' -- Change the language. Currently available (en or fr).

Config.GiveBlack          = true -- Wanna use Blackmoney?

-- Change the time it takes to open door then to break them.
-- Time in Seconde. 1000 = 1 seconde
Config.DoorOpenTime          = 2500
Config.DoorBrokenTime        = 5000
Config.WheelRemovalTime      = 5000
Config.ChopPriceMultiplier   = 0.10

Config.Zones = {
  {coords = vector3(-522.87, -1713.99, 18.33)},
  {coords = vector3(1515.42, -2145.54, 76.14)},
  {coords = vector3(2348.68, 3134.49, 47.21)}
}

Config.Blips = {
  {coords = vector3(-522.87, -1713.99, 0), name = _U('map_blip_chop'), color = 49, sprite = 225},
  {coords = vector3(1515.42, -2145.54, 0), name = _U('map_blip_chop'), color = 49, sprite = 225},
  {coords = vector3(2348.68, 3134.49, 0), name = _U('map_blip_chop'), color = 49, sprite = 225}
}
