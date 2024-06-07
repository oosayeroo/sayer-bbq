local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local IsBusy = false
local BBQTarget = {}
local BBQShop = {}
local BBQShopBlip = {}
local SharedItems = QBCore.Shared.Items

AddEventHandler('onResourceStart', function(t) if t ~= GetCurrentResourceName() then return end
    TriggerServerEvent('sayer-bbq:CheckForBBQs')
end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() 
    TriggerServerEvent('sayer-bbq:CheckForBBQs') 
end)

AddEventHandler('onResourceStop', function(t) if t ~= GetCurrentResourceName() then return end
    for k in pairs(BBQTarget) do exports['qb-target']:RemoveTargetEntity(k) end
    for k in pairs(BBQShop) do exports['qb-target']:RemoveTargetEntity(k) end
end)

function DebugCode(msg)
    if Config.DebugCode then
        print(msg)
    end
end

--notify configuration
function SendNotify(msg,type,time,title)
    if Config.NotifyScript == nil then DebugCode("Sayer Chopshop: Config.NotifyScript Not Set!") return end
    if not title then title = "Bus Job" end
    if not time then time = 5000 end
    if not type then type = 'success' end
    if not msg then DebugCode("SendNotify Client Triggered With No Message") return end
    if Config.NotifyScript == 'qb' then
        QBCore.Functions.Notify(msg,type,time)
    elseif Config.NotifyScript == 'okok' then
        exports['okokNotify']:Alert(title, msg, time, type, false)
    elseif Config.NotifyScript == 'qs' then
        exports['qs-notify']:Alert(msg, time, type)
    elseif Config.NotifyScript == 'other' then
        -- add your notify here
        exports['yournotifyscript']:Notify(msg,time,type)
    end
end

-- progressbar system
function ProgressBar(index, label, time)
    if not Config.UseProgressBar then
        return true
    end
    if not index then return false end
    if not label then return false end
    local ped = PlayerPedId()
    local statusValue = nil
    local time = time * 1000

    if GetResourceState('ox_lib') ~= 'missing' then 
        statusValue = exports.ox_lib:progressCircle({
            duration = time,
            position = 'middle',
            useWhileDead = false,
            canCancel = true,
            label = label,
            disable = {
                car = true,
                combat = true,
                move = true,
            },
        })
    elseif GetResourceState('mythic_progbar') ~= 'missing' then
        TriggerEvent("mythic_progbar:client:progress", {
            name = index,
            duration = time,
            label = label,
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {},
        }, function(status)
            statusValue = not status 
        end) 
        while statusValue == nil do
            Wait(10)
        end
    elseif GetResourceState('qb-core') ~= 'missing' then
        QBCore.Functions.Progressbar(index, label, time, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done   
            statusValue = true 
        end, function() -- Cancel
            statusValue = false
        end)

        while statusValue == nil do
            Wait(10)
        end
    end
    return statusValue
end

CreateThread(function()
    for k,v in pairs(Config.ShopLocations) do
        local model = ''
        local entity = ''
        model = v.PedModel
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
        end
      
        entity = CreatePed(0, model, v.Coords.x,v.Coords.y,v.Coords.z-1,v.Coords.w, false, false)
        SetEntityInvincible(entity,true)
        FreezeEntityPosition(entity,true)
        SetBlockingOfNonTemporaryEvents(entity,true)
        BBQShop["Ped"..v.Coords.x..v.Coords.y] =
        exports['qb-target']:AddTargetEntity(entity,{
            options = {
                {
                    action = function() 
                        OpenShopMenu() 
                    end,
                    icon = "fas fa-tag",
                    label = "Browse Shop",
                },
            },
            distance = 2.5,
        })
        if Config.ShopBlips.Show then
            BBQShopBlip["Blip"..v.Coords.x..v.Coords.y] = AddBlipForCoord(v.Coords.x,v.Coords.y,v.Coords.z)
            SetBlipSprite (BBQShopBlip["Blip"..v.Coords.x..v.Coords.y], Config.ShopBlips.Sprite)
            SetBlipDisplay(BBQShopBlip["Blip"..v.Coords.x..v.Coords.y], 4)
            SetBlipScale  (BBQShopBlip["Blip"..v.Coords.x..v.Coords.y], 0.8)
            SetBlipAsShortRange(BBQShopBlip["Blip"..v.Coords.x..v.Coords.y], true)
            SetBlipColour(BBQShopBlip["Blip"..v.Coords.x..v.Coords.y], Config.ShopBlips.Colour)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Config.ShopBlips.Label)
            EndTextCommandSetBlipName(BBQShopBlip["Blip"..v.Coords.x..v.Coords.y])
        end
    end
end)

function PlaceBBQ(x,y,z,w,prop,item)
    if not IsBusy then
        local ped = PlayerPedId()
        local emote = Config.Emotes.PlaceBBQ
        local time = Config.Timings.PlaceBBQ
        ExecuteCommand("e "..emote)
        if ProgressBar("place_bbq", "Placing BBQ...", time) then
            QBCore.Functions.TriggerCallback('sayer-bbq:PlaceDownBBQ', function(netId, citizenid)
                if netId then
                    success = true
                    while not DoesEntityExist(NetToObj(netId)) do Wait(0) end
                    local obj = NetToObj(netId)
                    while obj == nil do Wait(0) end
                    FreezeEntityPosition(obj, true)
                    PlaceObjectOnGroundProperly(obj)
                    local targetfinish = EnableBBQTarget(obj,item,citizenid)
                    while not targetfinish do Wait(0) end
                    DebugCode("Target Finished")
                end
            end, x, y, z, w, prop, item)
            while not success do
                Wait(0)
            end
            ClearPedTasks(ped)
        else
            ClearPedTasks(ped)
            SendNotify("Canceled", "error")
        end
    else
        SendNotify('Youre Busy', 'error')
    end
end

function PickUpBBQ(item,citizenid)
    if not IsBusy then
        local ped = PlayerPedId()
        local emote = Config.Emotes.PlaceBBQ
        local time = Config.Timings.PlaceBBQ
        ExecuteCommand("e "..emote)
        if ProgressBar("pickup_bbq", "Picking Up BBQ...", time) then
            TriggerServerEvent('sayer-bbq:PickupBBQ', item, citizenid)
            ClearPedTasks(ped)
            exports['qb-target']:RemoveTargetEntity(BBQTarget["BBQ"..citizenid])
        else
            ClearPedTasks(ped)
            SendNotify("Canceled", "error")
        end
    else
        SendNotify('Youre Busy', 'error')
    end
end

RegisterNetEvent('sayer-bbq:StartUpBBQs', function(netId, citizenid, item)
    if netId then
        DebugCode("Reached Client Side")
        while not DoesEntityExist(NetToObj(netId)) do Wait(0) end
        local obj = NetToObj(netId)
        while obj == nil do Wait(0) end
        FreezeEntityPosition(obj, true)
        PlaceObjectOnGroundProperly(obj)
        local targetfinish = EnableBBQTarget(obj,item,citizenid)
        while not targetfinish do Wait(0) end
        DebugCode("Target Finished")
    end
end)

RegisterNetEvent('sayer-bbq:SyncTargets', function(netId, citizenid, item)
    if netId then
        DebugCode("Reached Sync Targets")
        while not DoesEntityExist(NetToObj(netId)) do Wait(0) end
        local obj = NetToObj(netId)
        while obj == nil do Wait(0) end
        FreezeEntityPosition(obj, true)
        PlaceObjectOnGroundProperly(obj)
        local targetfinish = EnableBBQTarget(obj,item,citizenid)
        while not targetfinish do Wait(0) end
        DebugCode("Target Finished")
    end
end)

function EnableBBQTarget(obj,item,citizenid)
    local retval = false
    if obj ~= nil then
        local table = Config.Items[Item]
        BBQTarget["BBQ"..citizenid] = 
        exports['qb-target']:AddTargetEntity(obj,{
            options = {
                {
                    action = function() 
                        CookCats(citizenid) 
                    end,
                    icon = "fas fa-fire",
                    label = "Cook",
                },
                {
                    action = function() 
                        Refuel(item, citizenid) 
                    end,
                    icon = "fas fa-water",
                    label = "Refuel",
                },
                {
                    action = function() 
                        PickUpBBQ(item, citizenid) 
                    end,
                    icon = "fas fa-hand",
                    label = "Pick Up",
                    citizenid = citizenid,
                },
                {
                    action = function() 
                        JobDeleteBBQ(item, citizenid) 
                    end,
                    canInteract = function()
                        if GetDeleteJobAllowed() then
                            return true
                        end
                    end,
                    icon = "fas fa-hand",
                    label = "Remove BBQ",
                },
            },
            distance = 2.5,
        })
        retval = true
    end
    return retval
end

function JobDeleteBBQ(item,citizenid)
    TriggerServerEvent('sayer-bbq:PickupBBQ',item,citizenid)
end

function GetDeleteJobAllowed()
    local job = QBCore.Functions.GetPlayerData().job.name
    if Config.RemoveBBQ.Jobs[job] ~= nil then
        return true
    else
        return false
    end
end

function CookCats(citizenid)
    if not IsBusy then
        QBCore.Functions.TriggerCallback('sayer-bbq:GetFuelLevel', function(fuel)
            local current = fuel.Current
            local max = fuel.Max
            DebugCode("Fuel Current: "..tostring(current))
            DebugCode("Fuel Max: "..tostring(max))
            local titletext = "Fuel: "..tostring(current).."/"..tostring(max)
            local columns = {
                {
                    header = "BBQ",
                    text = titletext,
                    isMenuHeader = true,
                }, 
            }
            for k,v in pairs(Config.Recipes) do
                if v.Recipes ~= nil then
                    local item = {}
                    item.header = v.Label
                    local text = v.Description
                    item.text = text
                    item.params = {
                        event = CookMenu,
                        isAction = true,
                        args = {
                            citizenid = citizenid,
                            category = k,
                            current = fuel.Current,
                            max = fuel.Max,
                        }
                    }
                    table.insert(columns, item)
                end
            end
            exports['qb-menu']:openMenu(columns, true, true)
        end, citizenid)
    end
end

function CookMenu(data)
    local citizenid = data.citizenid
    local recipes = Config.Recipes[data.category].Recipes
    DebugCode("CID:"..citizenid)
    local Fuel = {
        Current = data.current,
        Max = data.max,
    }
    local columns = {
        {
            header = "BBQ",
            text = "Fuel: "..tostring(Fuel.Current).."/"..tostring(Fuel.Max),
            isMenuHeader = true,
        }, 
    }
    for k,v in pairs(recipes) do
        local item = {}
        item.header = SharedItems[k].label.."</br> Fuel Required: "..v.FuelRequired
        if Config.ShowItemImages then
            item.icon = k
        end
        local text = ""
        for d, j in pairs(v.Ingredients) do
            text = text .. "- " .. SharedItems[j.item].label .. ": " .. j.amount .. "<br>"
        end
        item.text = text
        item.params = {
            event = 'sayer-bbq:GetRecipe',
            args = {
                category = data.category,
                type = k,
                recipe = v.Ingredients,
                fuel = Fuel,
                citizenid = citizenid,
            }
        }
        table.insert(columns, item)
    end

    exports['qb-menu']:openMenu(columns, true, true)
end

RegisterNetEvent('sayer-bbq:GetRecipe', function(data)
    local category = data.category
    local citizenid = data.citizenid
    local item = data.type
    local ingredients = data.recipe
    local current = data.fuel.Current
    local max = data.fuel.Max
    local cooktime = Config.Recipes[data.category].Recipes[data.type].CookTime
    local RequiredFuel = Config.Recipes[data.category].Recipes[data.type].FuelRequired
    if RequiredFuel < current then
        QBCore.Functions.TriggerCallback("sayer-bbq:enoughIngredients", function(hasIngredients)
            if (hasIngredients) and not IsBusy then
                CookFood(item,RequiredFuel,citizenid, ingredients, cooktime)
            else
                QBCore.Functions.Notify("You do not have enough ingredients", "error")
                return
            end
        end, ingredients)
    else
        SendNotify("You Need More Fuel", 'error')
    end
end)

function CookFood(item,fuel,citizenid,ingredients, time)
    local emote = Config.Emotes.Cooking
    IsBusy = true
    ExecuteCommand("e "..emote)
    if ProgressBar('cooking_food', 'Cooking '..SharedItems[item].label, time) then
        SendNotify("Cooked "..SharedItems[item].label, 'success')
        TriggerServerEvent('sayer-bbq:GiveItem', item)
        TriggerServerEvent('sayer-bbq:RemoveFuel',fuel,citizenid)
        for k, v in pairs(ingredients) do
            TriggerServerEvent('sayer-bbq:RemoveItem', v.item, v.amount)
        end
        TriggerServerEvent('sayer-bbq:AddXP')
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        ClearPedTasks(PlayerPedId())
        IsBusy = false
    else 
        ClearPedTasks(PlayerPedId())
        QBCore.Functions.Notify('You Stopped Cooking', 'error')
        IsBusy = false
    end
end

function Refuel(item,citizenid)
    local fuel = Config.Items[item].Fuel
    local FuelType = fuel.Item
    local FillAmount = fuel.FillAmount
    local time = Config.Timings.Refuel
    local emote = Config.Emotes.Refuel
    if QBCore.Functions.HasItem(FuelType) then
        ExecuteCommand("e "..emote)
        IsBusy = true
        if ProgressBar('refuel_bbq', 'Refueling BBQ ', time) then
            TriggerServerEvent('sayer-bbq:Refuel',FuelType,FillAmount,citizenid,item)
            ClearPedTasks(PlayerPedId())
            IsBusy = false
        else 
            ClearPedTasks(PlayerPedId())
            SendNotify('Cancelled', 'error')
            IsBusy = false
        end
    else
        SendNotify("You Need Some "..SharedItems[FuelType].label.." To Refuel This BBQ", 'error')
    end
end

function OpenShopMenu()
    local columns = {
        {
            header = "BBQ Shop",
            text = "Browse Our Available Content",
            isMenuHeader = true,
        }, 
    }
    for k,v in pairs(Config.Shop) do
        if v.Stock ~= nil then
            local item = {}
            item.header = v.Label
            local text = v.Description
            item.text = text
            item.params = {
                event = StockMenu,
                isAction = true,
                args = {
                    category = k,
                }
            }
            table.insert(columns, item)
        end
    end
    exports['qb-menu']:openMenu(columns, true, true)
end

function StockMenu(data)
    local stock = Config.Shop[data.category].Stock
    local columns = {
        {
            header = Config.Shop[data.category].Label,
            isMenuHeader = true,
        }, 
    }
    for k,v in pairs(stock) do
        local item = {}
        item.header = SharedItems[k].label
        if Config.ShowItemImages then
            item.icon = k
        end
        local text = "$"..v.Cost
        item.text = text
        item.params = {
            event = 'sayer-bbq:AmountToBuy',
            args = {
                type = k,
                cost = v.Cost,
            }
        }
        table.insert(columns, item)
    end

    exports['qb-menu']:openMenu(columns, true, true)
end

RegisterNetEvent('sayer-bbq:AmountToBuy', function(data)
    local delmenu = nil
    
    delmenu = exports['qb-input']:ShowInput({
        header = "> Buying "..SharedItems[data.type].label.." <",
        submitText = "Confirm",
        inputs = {
            {
                text = "(#)Amount",    
                name = "amount",    
                type = "text",    
                isRequired = true,
            },
        }
    })
    if delmenu ~= nil then
        if delmenu.amount == nil then return end
        BuyShopItem(data.type,delmenu.amount,data.cost)
    end
end)

--returns amount of cash on player
function GetPlayerMoney(account)
    local has = QBCore.Functions.GetPlayerData().money[account]
    return has
end

function BuyShopItem(item,amount,cost)
    if item == nil then return end
    if cost == nil then return end
    local cash = GetPlayerMoney('cash')
    local total = cost * amount
    if cash >= total then
        TriggerServerEvent('sayer-bbq:BuyItem',item,amount,total)
    else
        local needed = total - cash
        SendNotify("You Are $"..needed.." Short For This", 'error')
    end
end