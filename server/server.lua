RegisterNetEvent('bridge:adjustBridgeHeight')
AddEventHandler('bridge:adjustBridgeHeight', function(height)
    -- Check permission or any additional validation here if needed
    TriggerClientEvent('bridge:syncBridgeHeight', -1, height) -- Sync height to all clients
end)
