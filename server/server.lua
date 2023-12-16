local initialBridgePosition = nil

-- Event to receive and store the initial bridge position from the client
RegisterServerEvent('PE-Bridge:SyncInitialPosition')
AddEventHandler('PE-Bridge:SyncInitialPosition', function(bridgePosition)
    initialBridgePosition = bridgePosition
end)

RegisterServerEvent('PE-Bridge:AdjustBridgeHeight')
AddEventHandler('PE-Bridge:AdjustBridgeHeight', function(amount)
    local source = source
    -- Calculate the new height based on the 'amount'
    local currentHeight = bridgeHeight or initialBridgePosition.z 
    local newHeight = currentHeight + amount

    -- Ensure the newHeight is within the valid range (minBridgeHeight to maxBridgeHeight)
    newHeight = math.min(math.max(newHeight, minBridgeHeight), maxBridgeHeight)

    -- Trigger the client event to update bridge height for all players
    TriggerClientEvent('PE-Bridge:SetBridgeHeight', -1, newHeight)
end)

-- Client-side event to receive and update bridge height
RegisterNetEvent('PE-Bridge:SetBridgeHeight')
AddEventHandler('PE-Bridge:SetBridgeHeight', function(newHeight)
    -- Update the bridge height in the client-side logic
    -- For example, if you're handling the bridge visuals on the client side, update it here
end)

-- Function to adjust the bridge height and trigger the server event
function adjustBridgeHeight(amount)
    TriggerServerEvent('PE-Bridge:AdjustBridgeHeight', amount)
end

-- Commands to raise/lower the bridge
RegisterCommand("raiseBridge", function()
    adjustBridgeHeight(10.0)
end, false)

RegisterCommand("lowerBridge", function()
    adjustBridgeHeight(-20.0)
end, false)

-- Example: Triggering the bridge spawn when a player joins
AddEventHandler('playerSpawned', function()
    TriggerClientEvent('PE-Bridge:spawnBridge', source)
end)


