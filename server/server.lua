local initialBridgePosition = nil

-- Event to receive and store the initial bridge position from the client
RegisterServerEvent('PE-Bridge:SyncInitialPosition')
AddEventHandler('PE-Bridge:SyncInitialPosition', function(bridgePosition)
    initialBridgePosition = bridgePosition
end)

RegisterServerEvent('PE-Bridge:AdjustBridgeHeight')
AddEventHandler('PE-Bridge:AdjustBridgeHeight', function(amount)
    local currentHeight = targetBridgeHeight or initialBridgePosition.z 
    local newHeight = currentHeight + amount
    newHeight = math.min(math.max(newHeight, minBridgeHeight), maxBridgeHeight)
    targetBridgeHeight = newHeight

    TriggerClientEvent('PE-Bridge:SetBridgeHeight', -1, newHeight)
end)

-- Client-side event to receive and update bridge height
RegisterNetEvent('PE-Bridge:SetBridgeHeight')
AddEventHandler('PE-Bridge:SetBridgeHeight', function(newHeight)
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





