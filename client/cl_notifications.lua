-- client/cl_notifications.lua
-- Notification system for bridge events

function ShowBridgeNotification(message, type)
    type = type or 'info'
    
    -- Try different notification systems
    if GetResourceState('es_extended') == 'started' then
        -- ESX
        ESX.ShowNotification(message)
    elseif GetResourceState('qb-core') == 'started' then
        -- QBCore
        QBCore.Functions.Notify(message, type)
    else
        -- Fallback to native
        SetNotificationTextEntry("STRING")
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end

RegisterNetEvent('bridge:notification')
AddEventHandler('bridge:notification', function(message, type)
    ShowBridgeNotification(message, type)
end)

RegisterNetEvent('bridge:sequence:started')
AddEventHandler('bridge:sequence:started', function(bridgeIndex)
    ShowBridgeNotification(('Bridge sequence started for bridge %d'):format(bridgeIndex), 'info')
end)

RegisterNetEvent('bridge:sequence:ended')
AddEventHandler('bridge:sequence:ended', function(bridgeIndex)
    ShowBridgeNotification(('Bridge sequence completed for bridge %d'):format(bridgeIndex), 'success')
end)

