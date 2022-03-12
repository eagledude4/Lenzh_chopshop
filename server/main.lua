local Vehicles   = {}
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	local vehicles = MySQL.Sync.fetchAll('SELECT * FROM vehicles')

	for i=1, #vehicles, 1 do
		local vehicle = vehicles[i]
		table.insert(Vehicles, vehicle)
	end
end)

ESX.RegisterServerCallback('lenzh_chopshop:getVehicles', function(source, cb)
	cb(Vehicles)
end)


--[[function Rewards(rewards)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return; end
    for k,v in pairs(Config.Items) do
        local randomCount = math.random(0, 3)
        xPlayer.addInventoryItem(v, randomCount)
    end
end

RegisterServerEvent("lenzh_chopshop:rewards")
AddEventHandler("lenzh_chopshop:rewards", function()
    Rewards()
end)

RegisterServerEvent('lenzh_chopshop:sell')
AddEventHandler('lenzh_chopshop:sell', function(itemName, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local price = Config.Itemsprice[itemName]
    local xItem = xPlayer.getInventoryItem(itemName)

    if xItem.count < amount then
        TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
        return
    end

    price = ESX.Math.Round(price * amount)

    if Config.GiveBlack then
        xPlayer.addAccountMoney('black_money', price)
    else
        xPlayer.addMoney(price)
    end

    xPlayer.removeInventoryItem(xItem.name, amount)
    TriggerClientEvent('esx:showNotification', source, _U('sold', amount, xItem.label, ESX.Math.GroupDigits(price)))
end)]]

RegisterServerEvent('lenzh_chopshop:payout')
AddEventHandler('lenzh_chopshop:payout', function(vehicleModel)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vehicleData = nil
    local string = nil

    for i=1, #Vehicles, 1 do
      if Vehicles[i].model == vehicleModel then
        vehicleData = Vehicles[i]
        break
      end
    end

    local price = vehicleData.price * Config.ChopPriceMultiplier
    if Config.GiveBlack then
        xPlayer.addAccountMoney('black_money', price)
        string = _U('payout_dirty')
    else
        xPlayer.addMoney(price)
        string = _U('payout_clean')
    end

    TriggerClientEvent('esx:showNotification', source, string, ESX.Math.GroupDigits(price))
end)
