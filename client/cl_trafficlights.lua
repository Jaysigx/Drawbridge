-- client/cl_trafficlights.lua
-- Traffic lights + proximity speed zones. Server-authoritative sync supported.

local trafficLights = {
    { model = 'prop_traffic_light_small_left',  targetVector = vector3(342.30206298828127,-2287.1923828125,12.45865440368652) },
    { model = 'prop_traffic_light_small_right', targetVector = vector3(352.6391906738281,-2287.287353515625,12.59946155548095) },
    { model = 'prop_traffic_light_small_left',  targetVector = vector3(364.49169921875,-2344.624755859375,12.59747886657714) },
    { model = 'prop_traffic_light_small_right', targetVector = vector3(353.939208984375,-2344.445556640625,12.45685005187988) },
    { model = 'prop_traffic_light_block',       targetVector = vector3(350.1459655761719,-2290.653076171875,16.54934310913086) },
    { model = 'prop_traffic_light_block',       targetVector = vector3(345.7252502441406,-2290.71875,16.2559642791748) },
    { model = 'prop_traffic_light_block',       targetVector = vector3(356.68670654296877,-2341.083984375,16.44212532043457) },
    { model = 'prop_traffic_light_block',       targetVector = vector3(362.175537109375,-2340.93212890625,16.28584289550781) },
}

local lightStates = {}
local LIGHT_STATES = { Green = 0, Red = 1, Yellow = 2, Reset = 3 }

-- cache + change detection for automatic zones
local cachedState = LIGHT_STATES.Green
local prevState   = LIGHT_STATES.Green

local SpeedZoneA, SpeedZoneB

local function resolveLight(lightIndex)
    local ld = trafficLights[lightIndex]
    if not ld then return 0 end
    return GetClosestObjectOfType(ld.targetVector.x, ld.targetVector.y, ld.targetVector.z, 2.0, ld.model, false, false, false)
end

function ToggleTrafficLight(lightIndex, state, sync)
    local entity = resolveLight(lightIndex)
    if entity ~= 0 and DoesEntityExist(entity) then
        SetEntityTrafficlightOverride(entity, state)
        lightStates[lightIndex] = state
        if sync then
            TriggerServerEvent('bridge:syncLights', lightStates)
        end
    else
        print(("Traffic light %d not found near target."):format(tonumber(lightIndex) or -1))
    end
end

-- Set all lights (local), optional sync to server
function ToggleAllTrafficLights(state, sync)
    cachedState = state
    for i = 1, #trafficLights do
        ToggleTrafficLight(i, state, false)
    end
    if sync then
        TriggerServerEvent('bridge:syncLights', lightStates)
    end
end

-- ===== Server -> client sync =====

-- single light from server
RegisterNetEvent('bridge:toggleTrafficLight')
AddEventHandler('bridge:toggleTrafficLight', function(lightIndex, state)
    ToggleTrafficLight(lightIndex, state, false)
end)

-- full lights state array from server
RegisterNetEvent('bridge:syncLights')
AddEventHandler('bridge:syncLights', function(newLightStates)
    lightStates = newLightStates or {}
    for i = 1, #trafficLights do
        local state = lightStates[i]
        if state ~= nil then ToggleTrafficLight(i, state, false) end
    end
end)

-- server asks to set all to one state
RegisterNetEvent('bridge:lights:setAll')
AddEventHandler('bridge:lights:setAll', function(state)
    ToggleAllTrafficLights(tonumber(state) or 0, false)
end)

-- server asks to enable/disable zones
RegisterNetEvent('bridge:traffic:zones')
AddEventHandler('bridge:traffic:zones', function(action)
    if action == 'enable' then
        enableTrafficZones()
    elseif action == 'disable' then
        disableTrafficZones()
    end
end)

-- ===== Proximity handling (optional) =====

local function isAnyPlayerNearLights()
    local players = GetActivePlayers()
    for _, p in ipairs(players) do
        local ped = GetPlayerPed(p)
        local pc  = GetEntityCoords(ped)
        for _, ld in ipairs(trafficLights) do
            if #(pc - ld.targetVector) <= 150.0 then
                return true
            end
        end
    end
    return false
end

if Config.ProximityTrafficLights then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if isAnyPlayerNearLights() then
                for i = 1, #trafficLights do
                    local s = lightStates[i]
                    if s ~= nil then ToggleTrafficLight(i, s, false) end
                end
            end
        end
    end)
end

-- ===== Commands / Exports =====

-- Fixed: use function param, not undefined args
exports('bridgelights', function(state)
    ToggleAllTrafficLights(tonumber(state) or 0, true)
end)

if Config.Commands then
    RegisterCommand("bridgelights", function(_, args)
        ToggleAllTrafficLights(tonumber(args[1]) or 0, true)
    end, false)
end

-- ===== Speed zones =====

function enableTrafficZones()
    if not SpeedZoneA then SpeedZoneA = AddRoadNodeSpeedZone(358.66, -2352.77, 10.2, 8.0, 0) end
    if not SpeedZoneB then SpeedZoneB = AddRoadNodeSpeedZone(347.90, -2278.23, 10.2, 8.0, 0) end
end

function disableTrafficZones()
    if SpeedZoneA then RemoveRoadNodeSpeedZone(SpeedZoneA); SpeedZoneA = nil end
    if SpeedZoneB then RemoveRoadNodeSpeedZone(SpeedZoneB); SpeedZoneB = nil end
end

-- Automatically toggle zones based on cached light state
if Config.AutomaticTrafficZones then
    Citizen.CreateThread(function()
        while true do
            if prevState ~= cachedState then
                prevState = cachedState
                if cachedState == LIGHT_STATES.Red then
                    enableTrafficZones()
                elseif cachedState == LIGHT_STATES.Green then
                    disableTrafficZones()
                elseif cachedState == LIGHT_STATES.Reset then
                    disableTrafficZones()
                    ToggleAllTrafficLights(LIGHT_STATES.Green, false)
                end
            end
            Citizen.Wait(1000)
        end
    end)
end
