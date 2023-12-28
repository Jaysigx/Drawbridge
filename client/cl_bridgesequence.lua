function BlinkBridgeLights( seconds )

    for _i = 1, math.floor( seconds / 2 ) do
        for lightIndex = 5, 8 do
            ToggleTrafficLight(lightIndex, 1, false)
        end
        Citizen.Wait(1000)
        for lightIndex = 5, 8 do
            ToggleTrafficLight(lightIndex, -1, false)
        end
        Citizen.Wait(1000)
    end

end

function OpenBridgeSequence()

    -- enable all traffic stop zones
    enableTrafficZones()
    
    -- turn all traffic lights red
    for lightIndex = 1, 8 do
        ToggleTrafficLight(lightIndex, 1, false)
    end

    -- blink for 10 seconds before lowering the gates to allow all traffic to cross
    BlinkBridgeLights( 10 )

    -- move all the gates down
    for gateIndex = 1, 4 do
        MoveGate(gateIndex, true)
    end
    
    -- blink for 5 seconds
    BlinkBridgeLights( 5 )

    -- move the bridge up
    Citizen.CreateThread(function()
        -- find the bridge entity
        if ModelExistsAtIndex(1) then
            EnsureBridgeEntity(1)
            MoveBridgeUp(1, 20)
        else
            print("Bridge " .. index .. " model does not exist.")
        end
    end)

    -- blink for 30 seconds
    BlinkBridgeLights( 30 )

    -- move the bridge down
    Citizen.CreateThread(function()
        -- find the bridge entity
        if ModelExistsAtIndex(1) then
            EnsureBridgeEntity(1)
            MoveBridgeDown(1, 20)
        else
            print("Bridge " .. index .. " model does not exist.")
        end
    end)

    -- blink for 35 seconds
    BlinkBridgeLights( 35 )

    -- move all the gates up
    for gateIndex = 1, 4 do
        MoveGate(gateIndex, false)
    end

    -- blink for 5 seconds
    BlinkBridgeLights( 5 )

    -- turn all traffic lightsgreen
    for lightIndex = 1, 8 do
        ToggleTrafficLight(lightIndex, 0, false)
    end

    disableTrafficZones()

end

RegisterCommand("bridgeSequence", function(source, args, rawCommand)
    TriggerServerEvent('bridge:OpenBridgeSequence')
end, false)

RegisterNetEvent('bridge:OpenBridgeSequence')
AddEventHandler('bridge:OpenBridgeSequence', function()
    OpenBridgeSequence()
end)