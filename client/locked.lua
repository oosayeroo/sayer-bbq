local QBCore = exports['qb-core']:GetCoreObject()

local PlacingCam  = false
local ShowBBQModel = false

local CurObject = {
    ID = nil,
    Alpha = 255,
    Model = nil,
    Item = nil,
}

local Placement = {
    x = 0.0,
    y = 0.0,
    z = 0.0,
    w = 0.0,
}

local RotationToDirection = function(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

local RayCastGamePlayCamera = function(distance)
    -- Checks to see if the Gameplay Cam is Rendering or another is rendering (no clip functionality)
    local currentRenderingCam = false
    if not IsGameplayCamRendering() then
        currentRenderingCam = GetRenderingCam()
    end

    local cameraRotation = not currentRenderingCam and GetGameplayCamRot() or GetCamRot(currentRenderingCam, 2)
    local cameraCoord = not currentRenderingCam and GetGameplayCamCoord() or GetCamCoord(currentRenderingCam)
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, b, c, _, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

local DrawTitle = function(text)
    SetTextScale(0.50, 0.50)
    SetTextFont(2)
    SetTextDropshadow(2.0, 0, 0, 0, 255)
    SetTextColour(255, 95, 85, 255)
    SetTextJustification(0)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.02)
end

StartEntityView = function()
    PlacingCam = true
    CreateThread(function()
        while PlacingCam do
            Wait(0)
            local playerPed    = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            if ShowBBQModel then
                local text = "Press "..Config.Controls.Confirm['confirmbbqplacement'].Control.." To Place BBQ "..Config.Controls.Confirm['cancelbbqplacement'].Control.." To Cancel"
                DrawTitle(text)
                local hit, coords, entity = RayCastGamePlayCamera(1000.0)
                if CurObject.ID ~= nil then
                    if DoesEntityExist(CurObject.ID) then
                        local x = QBCore.Shared.Round(coords.x, 2)
                        local y = QBCore.Shared.Round(coords.y, 2)
                        local z = QBCore.Shared.Round(coords.z, 2)
                        Placement.x = x
                        Placement.y = y
                        Placement.z = z
                        changeCoords()
                    end
                end
            end

            if ShowBBQModel == false then
                PlacingCam = false
            end
        end
    end)
end

function CheckBBQZones(x, y, z)
    local job = QBCore.Functions.GetPlayerData().job
    DebugCode("JOB: "..tostring(job.name))
    local gang = QBCore.Functions.GetPlayerData().gang
    DebugCode("GANG: "..tostring(gang.name))
    if CurObject.ID ~= nil then
        for k, v in pairs(Config.Zones) do
            if #(GetEntityCoords(CurObject.ID) - GetEntityCoords(PlayerPedId())) < Config.MaxPlacementDistance then
                if #(GetEntityCoords(CurObject.ID) - vec3(v.Coords.x, v.Coords.y, v.Coords.z)) < v.Radius then
                    if v.Blocked then
                        SendNotify("Cannot Place In This Area", 'error')
                        return false
                    elseif v.JobLocked then 
                        if v.JobLocked[job.name] then
                            return true
                        else
                            SendNotify("Cannot Place In This Area", 'error')
                            return false
                        end
                    elseif v.GangLocked then
                        if v.GangLocked[gang.name] then
                            return true
                        else
                            SendNotify("Cannot Place In This Area", 'error')
                            return false
                        end
                    end
                else
                    return true
                end
            else
                SendNotify("Too Far Away From You", 'error')
            end
        end
    else
        return false -- Return false if CurObject.ID is nil
    end
end


RegisterNetEvent('sayer-bbq:PlaceBBQ', function(item)
    if item ~= nil then
        if not PlacingCam then
            local table = Config.Items[item]
            local prop = table.Prop
            CurObject.Model = prop
            CurObject.Item = item
            StartBBQPlace(prop)
        else
            DebugCode("Camera Active")
        end
    else
        Debugcode("Item Returned Nil")
    end
end)


function StartBBQPlace(prop)
    local objectName = prop
    local ped = PlayerPedId()

    RequestModel(objectName)
    while not HasModelLoaded(objectName) do
        Wait(0)
    end

    local head      = GetEntityHeading(ped)
    local coords    = GetEntityCoords(ped)
    local forward   = GetEntityForwardVector(ped)
    local x, y, z   = table.unpack(coords + forward * 1.0)

    CurObject.ID = CreateObject(objectName, x, y, z, true, true, false)
    PlaceObjectOnGroundProperly(CurObject.ID)
    SetEntityHeading(CurObject.ID, head)
        
    Placement.x = x
    Placement.y = y
    Placement.z = z
    Placement.w = head
    SetEntityAlpha(CurObject.ID,102,false)
    CurObject.Alpha = 102
    SetEntityCollision(CurObject.ID,false,true)
    ShowBBQModel = true
    GroundCam = true
    StartEntityView()
end

function RemoveTempProp()
    if DoesEntityExist(CurObject.ID) then
        DeleteObject(CurObject.ID)
    end
    Placement = {
        x = 0.0,
        y = 0.0,
        z = 0.0,
        w = 0.0,
    }
    CurObject = {
        ID = nil,
        Alpha = 255,
        Model = nil,
        Item = nil,
    }
    PlacingCam  = false
    ShowBBQModel = false
end

local function changeCoord(axis, direction, rotate)
    local Tolerance = 2
    if CurObject.ID ~= nil then
        if rotate then
            Placement.w = Placement.w + Tolerance * direction
        else
            Placement[axis] = Placement[axis] + Tolerance * direction
        end
        changeCoords()
    end
end

function changeCoords()

    local playerPed = PlayerPedId()
    SetEntityCoords(CurObject.ID,Placement.x,Placement.y,Placement.z,false,false,false,false)
    SetEntityHeading(CurObject.ID,Placement.w)
    PlaceObjectOnGroundProperly(CurObject.ID)
    SetEntityCollision(CurObject.ID,false,true)
    SetEntityAlpha(CurObject.ID,CurObject.Alpha)
end

RegisterCommand("bbqrotateleft",    function() changeCoord("x", 1, true) end, false)
RegisterCommand("bbqrotateright",   function() changeCoord("x", -1, true) end, false)
RegisterCommand("confirmbbqplacement", function() 
    if PlacingCam then
        if ShowBBQModel then
            if CurObject.ID ~= nil then
                local retval = CheckBBQZones(Placement.x,Placement.y,Placement.z)
                if retval then
                    local x = QBCore.Shared.Round(Placement.x, 2)
                    local y = QBCore.Shared.Round(Placement.y, 2)
                    local z = QBCore.Shared.Round(Placement.z, 2)
                    local heading = QBCore.Shared.Round(Placement.w, 2)
                    DebugCode("SAYER BBQ");
                    DebugCode("Location = X: " .. x .. " Y: " .. y .. " Z: " .. z)
                    DebugCode("Heading = W: " .. heading)
                    PlaceBBQ(x,y,z,heading,CurObject.Model,CurObject.Item)
                    RemoveTempProp()
                end
            end
        end
    end
end, false)
RegisterCommand("cancelbbqplacement", function() 
    if PlacingCam then
        if ShowBBQModel then
            if CurObject.ID ~= nil then
                RemoveTempProp()
            end
        end
    end
end, false)

for k,v in pairs(Config.Controls.Rotate) do
    RegisterKeyMapping(k, v.Label,'keyboard',v.Control)
end 
for k,v in pairs(Config.Controls.Confirm) do
    RegisterKeyMapping(k, v.Label,'keyboard',v.Control)
end 