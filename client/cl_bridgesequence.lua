-- client/cl_bridgesequence.lua
-- Client only requests the server to run the authoritative sequence.
-- All lights, gates, and bridge motion are driven by the server.

RegisterCommand("bridgeSequence", function(_, args)
    local idx   = tonumber(args[1]) or 1
    local up    = tonumber(args[2]) or 20.0
    local down  = tonumber(args[3]) or 20.0
    local upSpd = tonumber(args[4]) or 0.18
    local dnSpd = tonumber(args[5]) or 0.28
    TriggerServerEvent('bridge:RunSequence', idx, up, down, upSpd, dnSpd)
end, false)

-- Optional: server can broadcast a start; clients forward it back to server
RegisterNetEvent('bridge:OpenBridgeSequence')
AddEventHandler('bridge:OpenBridgeSequence', function(idx, up, down, upSpd, dnSpd)
    TriggerServerEvent(
        'bridge:RunSequence',
        tonumber(idx)   or 1,
        tonumber(up)    or 20.0,
        tonumber(down)  or 20.0,
        tonumber(upSpd) or 0.18,
        tonumber(dnSpd) or 0.28
    )
end)
