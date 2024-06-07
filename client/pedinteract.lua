local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-bbq:StartConvo', function(data)
    exports['qb-menu']:openMenu({
        {header = "| Billy |",txt = "Hey Man hows it going?",isMenuHeader = true, },
        {header = "Im feeling good, Thank you",txt = "",params = {event = "qb-bbq:FeelingGood"}},
        {header = "Im not having a good day today",txt = "",params = {event = "qb-bbq:FeelingBad"}},
    })
end)

RegisterNetEvent('qb-bbq:FeelingGood', function(data)
    exports['qb-menu']:openMenu({
        {header = "| That is Great to hear Friend, you looking to buy some fresh BBQ products? |",isMenuHeader = true, },
        {header = "Yea i would love to browse your stuff",txt = "$ Buy $",params = {event = "qb-bbq:shop"}},
        {header = "No thank you, ill be going now",txt = "",params = {}},
    })
end)

RegisterNetEvent('qb-bbq:FeelingBad', function(data)
    exports['qb-menu']:openMenu({
        {header = "| Oh No that is a shame, can i interest you in some fresh BBQ products? |",isMenuHeader = true, },
        {header = "Sure, i guess so...",txt = "$ Buy $",params = {event = "qb-bbq:shop"}},
        {header = "No thank you, ill be going now",txt = "",params = {}},
    })
end)


CreateThread(function()
    if Config.EnableBBQShop == true then
        exports['qb-target']:SpawnPed({
            model = Config.BuyPed,
            coords = Config.BuyLocation, 
            minusOne = true, --may have to change this if your ped is in the ground
            freeze = true, 
            invincible = true, 
            blockevents = true,
            scenario = 'WORLD_HUMAN_DRUG_DEALER',
            target = { 
                options = {
                    {
                        type="client",
                        event = "qb-bbq:CheckConvo",
                        icon = "fas fa-smile",
                        label = "Greet"
                    }
                },
              distance = 2.5,
            },
        })
    end
end)