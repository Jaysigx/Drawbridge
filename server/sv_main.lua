RegisterServerEvent('syncBridgeSpawn')
AddEventHandler('syncBridgeSpawn', function()
    TriggerClientEvent('PE-Bridge:spawnBridge', -1) -- Send event to all clients
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerEvent('syncBridgeSpawn')
    end
end)

-- Function to move the bridge up and sync to clients
function MoveBridgeUp(index, amount)
    if bridgeEntities[index] and DoesEntityExist(bridgeEntities[index]) then
        local currentPosition = GetEntityCoords(bridgeEntities[index])
        local newHeight = math.min(currentPosition.z + amount, initialBridgePositions[index].z + maxBridgeHeight)
        TransitionBridgeHeight(bridgeEntities[index], newHeight)
        
        -- Trigger network event to sync the movement to clients
        TriggerClientEvent("bridge:moveUp", -1, index, amount)
        print("Moved Bridge " .. index .. " up by " .. amount .. " units.")
    else
        print("Bridge " .. index .. " entity does not exist.")
    end
end

-- Function to move the bridge down and sync to clients
function MoveBridgeDown(index, amount)
    if bridgeEntities[index] and DoesEntityExist(bridgeEntities[index]) then
        local currentPosition = GetEntityCoords(bridgeEntities[index])
        local newHeight = math.max(currentPosition.z - amount, initialBridgePositions[index].z + minBridgeHeights[index])
        TransitionBridgeHeight(bridgeEntities[index], newHeight)
        
        -- Trigger network event to sync the movement to clients
        TriggerClientEvent("bridge:moveDown", -1, index, amount)
        print("Moved Bridge " .. index .. " down by " .. amount .. " units.")
    else
        print("Bridge " .. index .. " entity does not exist.")
    end
end
