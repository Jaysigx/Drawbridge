local lightStates = {}

RegisterServerEvent('syncBridgeSpawn')
AddEventHandler('syncBridgeSpawn', function()
    TriggerClientEvent('bridge:spawnBridge', -1)
end)

-- Trigger bridge sync event when the resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerEvent('syncBridgeSpawn')
    end
end)

-- qbcore
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    TriggerClientEvent('bridge:syncLights', source, lightStates )
    TriggerClientEvent('bridge:spawnBridge', source)
end)

RegisterNetEvent('bridge:syncLights')
AddEventHandler('bridge:syncLights', function(storedStates)
    lightStates = storedStates
    TriggerClientEvent('bridge:syncLights', -1, lightStates )
end)

RegisterNetEvent('bridge:OpenBridgeSequence')
AddEventHandler('bridge:OpenBridgeSequence', function()
    TriggerClientEvent('bridge:OpenBridgeSequence', -1 )
end)

-- TODO: Use or delete?
-- -- Function to move the bridge up and sync to clients
-- function MoveBridgeUp(index, amount)
--     if bridgeEntities[index] and DoesEntityExist(bridgeEntities[index]) then
--         local currentPosition = GetEntityCoords(bridgeEntities[index])
--         local newHeight = math.min(currentPosition.z + amount, initialBridgePositions[index].z + maxBridgeHeight)
--         TransitionBridgeHeight(bridgeEntities[index], newHeight)
--         
--         -- Trigger network event to sync the movement to clients
--         TriggerClientEvent("bridge:moveUp", -1, index, amount)
--         print("Moved Bridge " .. index .. " up by " .. amount .. " units.")
--     else
--         print("Bridge " .. index .. " entity does not exist.")
--     end
-- end

-- Function to move the bridge down and sync to clients
-- function MoveBridgeDown(index, amount)
--     if bridgeEntities[index] and DoesEntityExist(bridgeEntities[index]) then
--         local currentPosition = GetEntityCoords(bridgeEntities[index])
--         local newHeight = math.max(currentPosition.z - amount, initialBridgePositions[index].z + minBridgeHeights[index])
--         TransitionBridgeHeight(bridgeEntities[index], newHeight)
--         
--         -- Trigger network event to sync the movement to clients
--         TriggerClientEvent("bridge:moveDown", -1, index, amount)
--         print("Moved Bridge " .. index .. " down by " .. amount .. " units.")
--     else
--         print("Bridge " .. index .. " entity does not exist.")
--     end
-- end
