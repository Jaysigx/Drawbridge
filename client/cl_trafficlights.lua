local trafficLights = {
    { model = 'prop_traffic_light_small_left', targetVector = vector3(342.30206298828127,-2287.1923828125,12.45865440368652) },
    { model = 'prop_traffic_light_small_right', targetVector = vector3(352.6391906738281,-2287.287353515625,12.59946155548095) },
    { model = 'prop_traffic_light_small_left', targetVector = vector3(364.49169921875,-2344.624755859375,12.59747886657714) },
    { model = 'prop_traffic_light_small_right', targetVector = vector3(353.939208984375,-2344.445556640625,12.45685005187988) },
    { model = 'prop_traffic_light_block', targetVector = vector3(350.1459655761719,-2290.653076171875,16.54934310913086) },
    { model = 'prop_traffic_light_block', targetVector = vector3(345.7252502441406,-2290.71875,16.2559642791748) },
    { model = 'prop_traffic_light_block', targetVector = vector3(356.68670654296877,-2341.083984375,16.44212532043457) },
    { model = 'prop_traffic_light_block', targetVector = vector3(362.175537109375,-2340.93212890625,16.28584289550781) }
}
local lightStates = {}

local LIGHT_STATES = {
    Green = 0,
    Red = 1,
    Yellow = 2,
    Reset = 3
}

local cachedState = LIGHT_STATES.Green
local prevState = state
local SpeedZoneA, SpeedZoneB

function ToggleTrafficLight(lightData, state)
    local entity = GetClosestObjectOfType(lightData.targetVector.x, lightData.targetVector.y, lightData.targetVector.z, 2.0, lightData.model, false, false, false)
    if DoesEntityExist(entity) then
        SetEntityTrafficlightOverride(entity, state)
        lightStates[lightData.model] = state
    else
        print("Error: Traffic light entity not found.")
    end
end

RegisterNetEvent('toggleTrafficLight')
AddEventHandler('toggleTrafficLight', function(lightData, state)
    if LIGHT_STATES[state] ~= nil then
        ToggleTrafficLight(lightData, LIGHT_STATES[state])
    else
        print("Error: Invalid traffic light state.")
    end
end)

function ToggleAllTrafficLights(state)
    cachedState = state
    for _, lightData in ipairs(trafficLights) do
        ToggleTrafficLight(lightData, state)
    end
end

Citizen.CreateThread(function()
    for _, lightData in ipairs(trafficLights) do
        ToggleTrafficLight(lightData, 0) -- Set lights to green on resource start
    end
end)


function IsPlayerNearLights()
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        local playerPed = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(playerPed)
        for _, lightData in ipairs(trafficLights) do
            local distance = #(playerCoords - lightData.targetVector)
            if distance <= 150.0 then
                return true
            end
        end
    end
    return false
end

function ToggleTrafficLightsBasedOnProximity()
    while true do
        Citizen.Wait(1000)
        if IsPlayerNearLights() then
            for _, lightData in ipairs(trafficLights) do
                local storedState = lightStates[lightData.model]
                ToggleTrafficLight(lightData, storedState)
            end
            TriggerServerEvent('syncLights', lightStates)
        end
    end
end

Citizen.CreateThread(ToggleTrafficLightsBasedOnProximity)

exports('bridgelights', function(state)
    local state = tonumber(args[1]) or 0
    ToggleAllTrafficLights(state)
end)

RegisterCommand("bridgelights", function(source, args, rawCommand)
    local state = tonumber(args[1]) or 0
    -- print("setting lights to", state, LIGHT_STATES.Red)
    ToggleAllTrafficLights(state)
end, false)

function TrafficAtBridge()
    while true do
        if prevState ~= cachedState then
            prevState = cachedState
            if cachedState == LIGHT_STATES.Red then
                print("Traffic lights are red, stopping traffic at the bridge.")
                SpeedZoneA = AddRoadNodeSpeedZone(358.66, -2352.77, 10.2, 8.0, 0)
                SpeedZoneB = AddRoadNodeSpeedZone(347.90, -2278.23, 10.2, 8.0, 0)
            elseif cachedState == LIGHT_STATES.Green then
                print("Traffic lights are green, resuming traffic at the bridge.")
                RemoveRoadNodeSpeedZone(SpeedZoneA)
                RemoveRoadNodeSpeedZone(SpeedZoneB)
            elseif cachedState == LIGHT_STATES.Reset then
                print("Resetting traffic lights at the bridge.")
                RemoveRoadNodeSpeedZone(SpeedZoneA)
                RemoveRoadNodeSpeedZone(SpeedZoneB)
                ToggleAllTrafficLights(LIGHT_STATES.Green) -- Reset all traffic lights to green
            else
                print("Invalid traffic light state.")
            end
        end
        Citizen.Wait(1000) -- Adjust the interval as needed
    end
end

Citizen.CreateThread(TrafficAtBridge)