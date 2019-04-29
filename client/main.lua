ESX                           = nil
local PlayerData              = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local isDead                  = false
local CurrentTask             = {}
local menuOpen 								= false
local wasOpen 								= false
local chopping 								= false


Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
    isDead = false
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.Zones.Shop.coords, true) < 3.0 then
			if not menuOpen then
				ESX.ShowHelpNotification(_U('shop_prompt'))

				if IsControlJustReleased(0, 38) then
					wasOpen = true
					OpenShop()
				end
			else
				Citizen.Wait(500)
			end
		else
			if wasOpen then
				wasOpen = false
				ESX.UI.Menu.CloseAll()
			end

			Citizen.Wait(500)
		end
	end
end)

function OpenShop()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen = true

	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.Itemsprice[v.name]

		if price and v.count > 0 then
			table.insert(elements, {
				label = ('%s - <span style="color:green;">%s</span>'):format(v.label, _U('item', ESX.Math.GroupDigits(price))),
				name = v.name,
				price = price,

				-- menu properties
				type = 'slider',
				value = 1,
				min = 1,
				max = v.count
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'car_shop', {
		title    = _U('shop_title'),
		align    = 'right',
		elements = elements
	}, function(data, menu)
		TriggerServerEvent('lenzh_chopshop:sell', data.current.name, data.current.value)
	end, function(data, menu)
		menu.close()
		menuOpen = false
	end)
end

function IsDriver ()
	return GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1)
end

function ChopVehicle()
	ESX.TriggerServerCallback('Lenzh_chopshop:isCooldown', function(cooldown)
		if cooldown <= 0 then
	local ped = GetPlayerPed(-1)
	local vehicle = GetVehiclePedIsIn( ped, false )
        exports.pNotify:SendNotification({text = "Chopping vehicle, please wait...", type = "error", timeout = 36000, layout = "centerRight", queue = "right", animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})

		SetVehicleEngineOn(vehicle, false, false, true)
		SetVehicleUndriveable(vehicle, false)
		SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, false, false)
		Citizen.Wait(5000)
		SetVehicleDoorBroken(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, true)
		Citizen.Wait(1000)
		SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, false, false)
		Citizen.Wait(5000)
		SetVehicleDoorBroken(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, true)
		Citizen.Wait(1000)
		SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, false, false)
		Citizen.Wait(5000)
		SetVehicleDoorBroken(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, true)
		Citizen.Wait(1000)
		SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, false, false)
		Citizen.Wait(5000)
		SetVehicleDoorBroken(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, true)
		Citizen.Wait(1000)
		SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, false, false)
		Citizen.Wait(5000)
		SetVehicleDoorBroken(GetVehiclePedIsIn(GetPlayerPed(-1), false),4, true)
		Citizen.Wait(1000)
		SetVehicleDoorOpen(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, false, false)
		Citizen.Wait(5000)
		SetVehicleDoorBroken(GetVehiclePedIsIn(GetPlayerPed(-1), false),5, true)
		Citizen.Wait(1000)
		DeleteVehicle()
        exports.pNotify:SendNotification({text = "Vehicle Chopped Successfully...", type = "success", timeout = 1000, layout = "centerRight", queue = "right", animation = {open = "gta_effects_fade_in", close = "gta_effects_fade_out"}})
	else
		ESX.ShowNotification(_U('cooldown', math.ceil(cooldown/1000)))
	    end
	end)
end

function DeleteVehicle()
	--[[ ESX.TriggerServerCallback('Lenzh_chopshop:isCooldown', function(cooldown)
	if cooldown <= 0 then ]]	
	if IsDriver() then
        local playerPed = GetPlayerPed(-1)
        local coords    = GetEntityCoords(playerPed)

        if IsPedInAnyVehicle(playerPed,  false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            ESX.Game.DeleteVehicle(vehicle)
		end
		
		TriggerServerEvent("lenzh_chopshop:rewards", rewards)

	  end
end


AddEventHandler('lenzh_chopshop:hasEnteredMarker', function(zone)
	if zone == 'Chopshop' and IsDriver() then
		CurrentAction     = 'Chopshop'
		CurrentActionMsg  = _U('press_to_chop')
		CurrentActionData = {}
	end

end)

AddEventHandler('lenzh_chopshop:hasExitedMarker', function(zone)
	if menuOpen then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

function CreateBlipCircle(coords, text, radius, color, sprite)
    
	local blip = AddBlipForCoord(coords)
	SetBlipSprite(blip, sprite)
	SetBlipColour(blip, color)
	SetBlipScale(blip, 0.8)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)

end

Citizen.CreateThread(function()
	if Config.EnableBlips == true then
	  for k,zone in pairs(Config.Zones) do
        CreateBlipCircle(zone.coords, zone.name, zone.radius, zone.color, zone.sprite)
	  end
   end
end)
--npc
Citizen.CreateThread(function()
    if Config.NPCEnable == true then
	RequestModel(Config.NPCHash)
	while not HasModelLoaded(Config.NPCHash) do
	Wait(1)

	end

	--PROVIDER
		meth_dealer_seller = CreatePed(1, Config.NPCHash, Config.NPCShop.x, Config.NPCShop.y, Config.NPCShop.z, Config.NPCShop.h, false, true)
		SetBlockingOfNonTemporaryEvents(meth_dealer_seller, true)
		SetPedDiesWhenInjured(meth_dealer_seller, false)
		SetPedCanPlayAmbientAnims(meth_dealer_seller, true)
		SetPedCanRagdollFromPlayerImpact(meth_dealer_seller, false)
		SetEntityInvincible(meth_dealer_seller, true)
		FreezeEntityPosition(meth_dealer_seller, true)
		TaskStartScenarioInPlace(meth_dealer_seller, "WORLD_HUMAN_SMOKING", 0, true);
	else
	end
end)

-- Display markers
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local coords, letSleep = GetEntityCoords(PlayerPedId()), true

        for k,v in pairs(Config.Zones) do
            if Config.MarkerType ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance then
                DrawMarker(Config.MarkerType, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
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
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
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

            if IsControlJustReleased(0, 38) then
                if IsDriver() then
                    if CurrentAction == 'Chopshop' then
					ChopVehicle()					
                    end
                end
                CurrentAction = nil
            end
        else
            Citizen.Wait(500)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuOpen then
			ESX.UI.Menu.CloseAll()
		end
	end
end)