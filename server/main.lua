local QBCore = exports['qb-core']:GetCoreObject()
local BBQOUT = {}
local SharedItems = QBCore.Shared.Items

AddEventHandler('onResourceStop', function(t) if t ~= GetCurrentResourceName() then return end
    for k, v in pairs(BBQOUT) do 
        if DoesEntityExist(v.entity) then
            DeleteEntity(v.entity) 
        end
    end
end)

function DebugCode(msg)
    if Config.DebugCode then
        print(msg)
    end
end

function SendNotify(src, msg, type, time, title)
    if not title then title = "Chop Shop" end
    if not time then time = 5000 end
    if not type then type = 'success' end
    if not msg then DebugCode("SendNotify Server Triggered With No Message") return end
    if Config.NotifyScript == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, msg, type, time)
    elseif Config.NotifyScript == 'okok' then
        TriggerClientEvent('okokNotify:Alert', src, title, msg, time, type, false)
    elseif Config.NotifyScript == 'qs' then
        TriggerClientEvent('qs-notify:Alert', src, msg, time, type)
    elseif Config.NotifyScript == 'other' then
        --add your notify event here
    end
end

for k,v in pairs(Config.Items) do
    QBCore.Functions.CreateUseableItem(k, function(source, item)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        local citizenid = Player.PlayerData.citizenid
        if BBQOUT[citizenid] == nil then
            TriggerClientEvent("sayer-bbq:PlaceBBQ", src, k)
        else
            SendNotify(src, "You Have a BBQ Out Already", 'error')
        end
    end)
end

RegisterNetEvent('sayer-bbq:BuyItem', function(item, amount, total)
    if not amount then amount = 1 end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveMoney('cash',total) then
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', source, SharedItems[item], "add")
        SendNotify(src,"You Bought x"..amount.." ["..SharedItems[item].label.."]", 'success')
    end
end)

RegisterNetEvent('sayer-bbq:GiveItem', function(item, amount)
    if not amount then amount = 1 end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', source, SharedItems[item], "add")
end)

RegisterNetEvent('sayer-bbq:RemoveItem', function(item, amount)
    if not amount then amount = 1 end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', source, SharedItems[item], "remove")
end)

RegisterNetEvent('sayer-bbq:CheckForBBQs', function()
    local bbqs = MySQL.query.await('SELECT * FROM sayer_bbq', {})
    for _, v in pairs(bbqs) do
        local item = v.item
        DebugCode("item:"..item)
        local citizenid = v.citizenid
        DebugCode("citizenid:"..citizenid)
        local fuel = json.decode(v.fuel)
        local fuelcurrent = fuel.Current
        DebugCode("fuelcurrent:"..tostring(fuelcurrent))
        local fuelmax = fuel.Max
        DebugCode("fuelmax:"..tostring(fuelmax))
        if fuelcurrent > fuelmax then
            fuelcurrent = fuelmax
        end
        if fuelcurrent < 0 then
            fuelcurrent = 0
        end
        local coords = json.decode(v.coords)
        local x = coords.x
        DebugCode("x:"..x)
        local y = coords.y
        DebugCode("y:"..y)
        local z = coords.z
        DebugCode("z:"..z)
        local w = coords.w
        DebugCode("w:"..w)
        local prop = v.prop
        DebugCode("prop:"..prop)
        if BBQOUT[citizenid] == nil then
            local obj = CreateObject(GetHashKey(prop), x,y,z,true, true, true)
            while not DoesEntityExist(obj) do Wait(0) end
            SetEntityHeading(obj, w)
            local netId = NetworkGetNetworkIdFromEntity(obj)
            BBQOUT[citizenid] = { netID = netId, entity = obj }
            DebugCode("BBQ Created")
            TriggerClientEvent('sayer-bbq:StartUpBBQs',-1,netId, citizenid, item)
        else
            local netId = BBQOUT[citizenid].netID
            local entity = BBQOUT[citizenid].entity
            TriggerClientEvent('sayer-bbq:SyncTargets',-1,netId,citizenid,item)
        end
    end
end)

RegisterNetEvent('sayer-bbq:PickupBBQ', function(item,citizenid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    MySQL.rawExecute('SELECT * FROM sayer_bbq WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            MySQL.query('DELETE FROM sayer_bbq WHERE citizenid = ?', { citizenid })
            if BBQOUT[citizenid].entity ~= nil then
                if DoesEntityExist(BBQOUT[citizenid].entity) then
                    DeleteEntity(BBQOUT[citizenid].entity)
                end
            end
            Player.Functions.AddItem(item,1)
            SendNotify(src,"BBQ Picked Up")
            BBQOUT[citizenid] = nil
        else
            DebugCode("BBQ Not Found")
        end
    end)
end)

RegisterNetEvent('sayer-bbq:RemoveFuel', function(fuel,citizenid)
    MySQL.rawExecute('SELECT fuel FROM sayer_bbq WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            local Fuel = {}
            if result and result[1] then Fuel = json.decode(result[1].fuel) end
            DebugCode("RemoveFuel: Current: "..tostring(Fuel["Current"]))
            DebugCode("RemoveFuel: Max: "..tostring(Fuel["Max"]))
            Fuel["Current"] = Fuel["Current"] - fuel
            if Fuel["Current"] < 0 then
                Fuel["Current"] = 0
            end
            DebugCode("RemoveFuel: RemoveAmount: "..tostring(fuel))
            DebugCode("RemoveFuel: New Current: "..tostring(Fuel["Current"]))
            local table = json.encode(Fuel)
            MySQL.update('UPDATE sayer_bbq SET fuel = ? WHERE citizenid = ?', { table, citizenid })
        end    
    end)
end)

RegisterNetEvent('sayer-bbq:Refuel', function(fuelitem,fuelamount,citizenid,bbqitem)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    MySQL.rawExecute('SELECT fuel FROM sayer_bbq WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            local Fuel = {}
            if result and result[1] then Fuel = json.decode(result[1].fuel) end
            local maxfuel = Config.Items[bbqitem].Fuel.MaxFuel
            DebugCode("ReFuel: Current: "..tostring(Fuel["Current"]))
            DebugCode("ReFuel: Max: "..tostring(Fuel["Max"]))
            Fuel["Current"] = Fuel["Current"] + fuelamount
            if Fuel["Current"] > maxfuel then
                Fuel["Current"] = maxfuel
            end
            DebugCode("ReFuel: AddAmount: "..tostring(fuelamount))
            DebugCode("ReFuel: New Current: "..tostring(maxfuel))
            local table = json.encode(Fuel)
            MySQL.update('UPDATE sayer_bbq SET fuel = ? WHERE citizenid = ?', { table, citizenid })
            Player.Functions.RemoveItem(fuelitem,1)
            SendNotify(src,"Fuel Level Set To ["..tostring(Fuel["Current"]).."/"..tostring(Fuel["Max"]).."]")
        end    
    end)
end)


QBCore.Functions.CreateCallback('sayer-bbq:GetFuelLevel', function(source, cb, citizenid)
    MySQL.rawExecute('SELECT fuel FROM sayer_bbq WHERE citizenid = ?', { citizenid }, function(result)
        if result[1] then
            local Fuel = {}
            if result and result[1] then Fuel = json.decode(result[1].fuel) end
            cb(Fuel)
        end    
    end)
end)

QBCore.Functions.CreateCallback('sayer-bbq:PlaceDownBBQ', function(source, cb, x, y, z, w, prop, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    DebugCode(tostring(citizenid))
    local fuellimit = Config.Items[item].Fuel.MaxFuel
    local fuel = {
        Current = 0,
        Max = fuellimit,
    }
    local Coords = {
        x = x,
        y = y,
        z = z,
        w = w,
    }
    MySQL.insert('INSERT INTO sayer_bbq (citizenid, prop, item, fuel, coords) VALUES (?, ?, ?, ?, ?)', {
        citizenid,
        prop,
        item,
        json.encode(fuel),
        json.encode(Coords)
    })
    local obj = CreateObject(GetHashKey(prop), x,y,z,true, true, true)
    while not DoesEntityExist(obj) do Wait(0) end
    SetEntityHeading(obj, w)
    local netId = NetworkGetNetworkIdFromEntity(obj)
    BBQOUT[citizenid] = { netID = netId, entity = obj }
    Player.Functions.RemoveItem(item,1)
    cb(netId, citizenid)
end)    

----Recipe Item Callbacks

QBCore.Functions.CreateCallback('sayer-bbq:enoughIngredients', function(source, cb, Ingredients)
    local src = source
    local hasItems = false
    local idk = 0
    local player = QBCore.Functions.GetPlayer(source)
    for k, v in pairs(Ingredients) do
        if player.Functions.GetItemByName(v.item) and player.Functions.GetItemByName(v.item).amount >= v.amount then
            idk = idk + 1
            if idk == #Ingredients then
                cb(true)
            end
        else
            cb(false)
            return
        end
    end
end)

RegisterNetEvent('sayer-bbq:AddXP', function()
    local src = source
    local field = 'bbq'
    local xp = 5
    exports['sayer-reputation']:AddXP(src,field,xp)
end)