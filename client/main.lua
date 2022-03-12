ESX                             = nil
local PlayerData                = {}
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local isDead                    = false


AddEventHandler('esx:onPlayerDeath', function(data)
    isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
    isDead = false
end)

AddEventHandler('lenzh_chopshop:hasEnteredMarker', function(zone)
	CurrentAction     = 'Chopshop'
	CurrentActionMsg  = _U('press_to_chop')
	CurrentActionData = {}
end)

AddEventHandler('lenzh_chopshop:hasExitedMarker', function(zone)
	CurrentAction = nil
end)


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

function chopVehicle()
  local ped = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(ped, false)
  local vehicleModel = GetEntityModel(vehicle)
  local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
  local vehicleNameLower = string.lower(vehicleName)
  local numDoors = GetNumberOfVehicleDoors(vehicle)
  local numWheels = GetVehicleNumberOfWheels(vehicle)

  TaskLeaveVehicle(ped, vehicle, 0)
  SetVehicleEngineOn(vehicle, false, false, true)
  SetVehicleUndriveable(vehicle, true)
  SetVehicleDoorsLocked(vehicle, 2) --https://docs.fivem.net/natives/?_0xB664292EAECF7FA6
  SetVehicleDoorsLockedForAllPlayers(vehicle, false)

  local expectedTime = (Config.DoorOpenTime + Config.DoorBrokenTime) * numDoors
  exports.pNotify:SendNotification({text = "Removing Doors...", type = "error", timeout = expectedTime, layout = "centerRight", queue = "right", animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
  for i=0, numDoors + 1, 1 do
    Citizen.Wait(Config.DoorOpenTime)
    SetVehicleDoorOpen(vehicle, i, false, false)
    Citizen.Wait(Config.DoorBrokenTime)
    SetVehicleDoorBroken(vehicle, i, true)
  end

  local expectedTime = Config.WheelRemovalTime * numWheels
  exports.pNotify:SendNotification({text = "Removing Wheels...", type = "error", timeout = expectedTime, layout = "centerRight", queue = "right", animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
  for i=0, numWheels + 1, 1 do
    Citizen.Wait(Config.WheelRemovalTime)
    SetVehicleWheelTireColliderSize(vehicle, i, -5.0)
  end

  ESX.Game.DeleteVehicle(vehicle)
  exports.pNotify:SendNotification({text = "Vehicle Chopped Successfully...", type = "success", timeout = 1000, layout = "centerRight", queue = "right", animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
  TriggerServerEvent('lenzh_chopshop:payout', vehicleNameLower)
end

RegisterNetEvent('lenzh_chopshop:chopVehicle')
AddEventHandler('lenzh_chopshop:chopVehicle', function()

end)

function createBlip(coords, text, color, sprite)
	local blip = AddBlipForCoord(coords)
	SetBlipSprite(blip, sprite)
	SetBlipColour(blip, color)
	SetBlipScale(blip, 0.8)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end


--Create Blips
Citizen.CreateThread(function()
	if Config.EnableBlips == true then
	  for k,zone in pairs(Config.Blips) do
        createBlip(zone.coords, zone.name, zone.color, zone.sprite)
	  end
   end
end)


-- Display markers
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local coords, letSleep = GetEntityCoords(PlayerPedId()), true
        for k,v in pairs(Config.Zones) do
          if Config.MarkerType ~= -1 and GetDistanceBetweenCoords(coords, v.coords, true) < Config.DrawDistance and not IsPedOnFoot(PlayerPedId()) then
            DrawMarker(Config.MarkerType, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSizeL.x, Config.MarkerSizeL.y, Config.MarkerSizeL.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
            letSleep = false
          end
        end

        if letSleep then
          Citizen.Wait(500)
        end
    end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil
		local letSleep = true

		for k,v in pairs(Config.Zones) do
			if(GetDistanceBetweenCoords(coords, v.coords, true) < Config.MarkerSizeL.x) and not IsPedOnFoot(PlayerPedId()) then
				isInMarker  = true
				currentZone = k
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('lenzh_chopshop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('lenzh_chopshop:hasExitedMarker', LastZone)
		end

	end
end)

-- Key controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if CurrentAction ~= nil then
            ESX.ShowHelpNotification(CurrentActionMsg)

            if IsControlJustReleased(0, 38) then -- Input pickup, E by default
							if CurrentAction == 'Chopshop' then
							 chopVehicle()
							end
              CurrentAction = nil
            end
        else
            Citizen.Wait(500)
        end
    end
end)
