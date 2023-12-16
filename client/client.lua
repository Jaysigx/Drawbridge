
local bridgeObject = nil
local initialBridgePosition = vector3(353.3317, -2315.838, 6.8615)
local targetBridgeHeight = initialBridgePosition.z
local bridgeMovementSpeed = 0.009
local maxBridgeHeight = initialBridgePosition.z + 30.0
local minBridgeHeight = initialBridgePosition.z


local QBCore = exports['qb-core']:GetCoreObject()

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('PE-Bridge:spawnBridge')
end)
    
RegisterNetEvent('PE-Bridge:spawnBridge')
AddEventHandler('PE-Bridge:spawnBridge', function(initialPosition)
    if not bridgeObject then
        bridgeObject = CreateObject(GetHashKey('car_drawbridge'), initialBridgePosition.x, initialBridgePosition.y, initialBridgePosition.z, true, true, true)
        FreezeEntityPosition(bridgeObject, true)
        SetEntityInvincible(bridgeObject, true)
    end
end)

RegisterCommand("spawnbridge", function()
    TriggerServerEvent('PE-Bridge:spawnBridge', initialBridgePosition)
end, false)

function SpawnBridgeIfNotExists()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    if playerCoords then
        local bridgeCoords = initialBridgePosition
        if bridgeCoords then
            local distance = #(playerCoords - bridgeCoords)
            --print("Distance between player and PE-Bridge:", distance)
            if distance < 150.0 and not DoesEntityExist(bridgeObject) then
                TriggerEvent('PE-Bridge:spawnBridge', initialBridgePosition)
            end
        else
            print("Bridge object coordinates are nil.")
        end
    else
        print("Player coordinates are nil.")
    end
end

local function GetBridgeHeight()
    return 6.8615 -- Sample height; replace with your logic to retrieve the bridge height
end



local function CheckBridgeHeight()
    local bridgeHeight = GetBridgeHeight()
    print("Bridge height is:", bridgeHeight)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) -- Adjust the interval as needed
        CheckBridgeHeight()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Adjust the interval as needed
        SpawnBridgeIfNotExists()
    end
end)

function Lerp(start, stop, t)
    return start + (stop - start) * t
end

local function adjustBridgeHeight(amount)
    if bridgeObject then
        local startingHeight = GetEntityCoords(bridgeObject).z
        if startingHeight == initialBridgePosition.z then
            startingHeight = initialBridgePosition.z + 30.0
        end
        local targetHeight = math.min(math.max(startingHeight + amount, minBridgeHeight), maxBridgeHeight)
        targetBridgeHeight = targetHeight
        TriggerServerEvent('PE-Bridge:adjustBridgeHeight', targetBridgeHeight)
        if targetBridgeHeight >= maxBridgeHeight then
            print("Bridge reached maximum height.")
        elseif targetBridgeHeight <= minBridgeHeight then
            print("Bridge reached minimum height.")
        end
    end
end

RegisterCommand("raiseBridge", function()
    adjustBridgeHeight(10.0)
end, false)

RegisterCommand("lowerBridge", function()
    adjustBridgeHeight(-20.0)
end, false)

Citizen.CreateThread(function()
    TriggerEvent('PE-Bridge:spawnBridge')

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

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if bridgeObject then
            DeleteEntity(bridgeObject)
            bridgeObject = nil
        end
    end
end)
