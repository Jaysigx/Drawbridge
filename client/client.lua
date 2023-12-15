local bridgeObject = nil
local initialBridgePosition = vector3(353.3317, -2315.838, 6.9)
local targetBridgeHeight = initialBridgePosition.z
local bridgeMovementSpeed = 0.005
local maxBridgeHeight = initialBridgePosition.z + 30.0
local minBridgeHeight = initialBridgePosition.z

RegisterNetEvent('bridge:spawnBridge')
AddEventHandler('bridge:spawnBridge', function()
    if not bridgeObject then
        bridgeObject = CreateObject(GetHashKey('car_drawbridge'), initialBridgePosition.x, initialBridgePosition.y, initialBridgePosition.z, true, true, true)
        FreezeEntityPosition(bridgeObject, true)
        SetEntityInvincible(bridgeObject, true)
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
        TriggerServerEvent('bridge:adjustBridgeHeight', targetBridgeHeight)
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
    adjustBridgeHeight(-10.0)
end, false)

Citizen.CreateThread(function()
    TriggerEvent('bridge:spawnBridge')

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
