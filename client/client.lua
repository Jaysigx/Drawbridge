local bridgeObject = nil
local initialBridgePosition = Config.BridgePosition
local targetBridgeHeight = initialBridgePosition.z
local bridgeMovementSpeed = 0.009
local maxBridgeHeight = initialBridgePosition.z + 30.0
local minBridgeHeight = initialBridgePosition.z
local model = GetHashKey'car_drawbridge'




local function PrepareModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
end

-- Function to create an object after preparing the model
local bridgeObjectCreated = false

local function CreateBridgeObject()
    PrepareModel(model)
    if not bridgeObjectCreated then
        bridgeObject = CreateObject(model, initialBridgePosition.x, initialBridgePosition.y, initialBridgePosition.z, true, true, true)
        if bridgeObject ~= nil and bridgeObject ~= 0 then
            SetEntityLodDist(bridgeObject, 500)
            SetEntityAsMissionEntity(bridgeObject, true, true)
            FreezeEntityPosition(bridgeObject, true)
            SetEntityInvincible(bridgeObject, true)
            bridgeObjectCreated = true -- Set the flag to true after creating the bridge object
        else
            print("Failed to create the bridge object. Model may be invalid.")
        end
    end
end


Citizen.CreateThread(function()
    TriggerServerEvent('PE-Bridge:SyncInitialPosition', initialBridgePosition)
end)

AddEventHandler('playerSpawned', function()
    CreateBridgeObject()
end)


RegisterCommand("spawnbridge", function()
    CreateBridgeObject()
end, false)

local isBridgeSpawned = false

function SpawnBridgeIfNotExists()
    Citizen.CreateThread(function()
        PrepareModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(100)
        end

        while true do
            Citizen.Wait(1000) 

            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            if playerCoords then
                local bridgeCoords = initialBridgePosition.coords -- Check this line
                if bridgeCoords then
                    local distance = #(playerCoords - bridgeCoords)
                    print("Distance between player and PE-Bridge:", distance)

                    if distance < 150.0 and not isBridgeSpawned then
                        CreateBridgeObject()
                        isBridgeSpawned = true
                    elseif distance >= 150.0 and isBridgeSpawned then
                        DeleteEntity(bridgeObject)
                        bridgeObject = nil
                        isBridgeSpawned = false
                    end
                else
                    print("Bridge object coordinates are nil.")
                end
            else
                print("Player coordinates are nil.")
            end
        end
    end)
end




local function AdjustBridgeHeight(amount)
    if bridgeObject then
        local startingHeight = GetEntityCoords(bridgeObject).z
        local targetHeight = math.min(math.max(startingHeight + amount, minBridgeHeight), maxBridgeHeight)
        targetBridgeHeight = targetHeight
    end
end

RegisterCommand("raiseBridge", function()
    AdjustBridgeHeight(10.0)
end, false)

RegisterCommand("lowerBridge", function()
    AdjustBridgeHeight(-20.0)
end, false)


function Lerp(start, stop, t)
    return start + (stop - start) * t
end

-- Handling bridge movement
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if bridgeObject and targetBridgeHeight ~= 0 then
            local currentPos = GetEntityCoords(bridgeObject)
            local targetPos = vector3(currentPos.x, currentPos.y, initialBridgePosition.z + targetBridgeHeight)
            local distance = Vdist(currentPos, targetPos)
            local duration = (distance / bridgeMovementSpeed) * 10

            if duration > 0 then
                local startTime = GetGameTimer()
                local endTime = startTime + duration

                while GetGameTimer() < endTime do
                    local elapsed = GetGameTimer() - startTime
                    local t = elapsed / duration
                    local newHeight = Lerp(currentPos.z, targetPos.z, t)
                    SetEntityCoordsNoOffset(bridgeObject, currentPos.x, currentPos.y, newHeight, true, true, true)
                    Citizen.Wait(0)
                end

                SetEntityCoordsNoOffset(bridgeObject, currentPos.x, currentPos.y, targetPos.z, true, true, true)

                if targetBridgeHeight >= maxBridgeHeight or targetBridgeHeight <= minBridgeHeight then
                    targetBridgeHeight = 0
                end
            end
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
      CreateBridgeObject()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if bridgeObject then
            DeleteEntity(bridgeObject)
            bridgeObject = nil
        end
    end
end)
