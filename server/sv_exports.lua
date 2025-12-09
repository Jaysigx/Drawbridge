-- server/sv_exports.lua
-- Server-side exports for other resources to interact with the bridge system

local resourceName = GetCurrentResourceName()

-- Get bridge state exports (from sv_state.lua)
local GetBridgeState = exports[resourceName]:GetBridgeState
local SetBridgeState = exports[resourceName]:SetBridgeState
local GetLightState = exports[resourceName]:GetLightState
local SetLightState = exports[resourceName]:SetLightState
local SetAllLightStates = exports[resourceName]:SetAllLightStates
local CanStartSequence = exports[resourceName]:CanStartSequence
local RegisterSequence = exports[resourceName]:RegisterSequence
local UnregisterSequence = exports[resourceName]:UnregisterSequence
local IsSequenceActive = exports[resourceName]:IsSequenceActive

-- Bridge control exports
exports('MoveBridge', function(index, delta, speed)
    -- Move bridge by delta amount
    -- @param index: number (1 or 2) - Bridge index
    -- @param delta: number - Amount to move (positive = up, negative = down)
    -- @param speed: number (optional) - Movement speed in m/s
    -- @return: boolean - Success status
    if type(index) ~= 'number' or type(delta) ~= 'number' then return false end
    TriggerEvent('bridge:serverMove', index, delta, speed)
    return true
end)

exports('SetBridgeHeight', function(index, height, speed)
    -- Set bridge to absolute height
    -- @param index: number (1 or 2) - Bridge index
    -- @param height: number - Absolute Z height
    -- @param speed: number (optional) - Movement speed in m/s
    -- @return: boolean - Success status
    if type(index) ~= 'number' or type(height) ~= 'number' then return false end
    TriggerEvent('bridge:serverSet', index, height, speed)
    return true
end)

exports('GetBridgeHeight', function(index)
    -- Get current bridge height
    -- @param index: number (1 or 2) - Bridge index
    -- @return: number|nil - Current bridge Z height
    local state = GetBridgeState(index)
    return state and state.z or nil
end)

exports('IsBridgeMoving', function(index)
    -- Check if bridge is currently moving
    -- @param index: number (1 or 2) - Bridge index
    -- @return: boolean - True if moving
    local state = GetBridgeState(index)
    return state and state.moving or false
end)

-- Light control exports
exports('SetTrafficLight', function(lightIndex, state)
    -- Set individual traffic light state
    -- @param lightIndex: number (1-8) - Light index
    -- @param state: number - Light state (0=Green, 1=Red, 2=Yellow, 3=Reset)
    -- @return: boolean - Success status
    if type(lightIndex) ~= 'number' or type(state) ~= 'number' then return false end
    SetLightState(lightIndex, state)
    TriggerClientEvent('bridge:toggleTrafficLight', -1, lightIndex, state)
    return true
end)

exports('SetAllTrafficLights', function(state)
    -- Set all traffic lights to same state
    -- @param state: number - Light state (0=Green, 1=Red, 2=Yellow, 3=Reset)
    -- @return: boolean - Success status
    if type(state) ~= 'number' then return false end
    local states = {}
    for i = 1, 8 do
        states[i] = state
    end
    SetAllLightStates(states)
    TriggerClientEvent('bridge:syncLights', -1, states)
    return true
end)

exports('GetTrafficLightState', function(lightIndex)
    -- Get traffic light state
    -- @param lightIndex: number (1-8) - Light index
    -- @return: number|nil - Current light state
    return GetLightState(lightIndex)
end)

-- Gate control exports
exports('SetGate', function(gateIndex, isDown)
    -- Set individual gate position
    -- @param gateIndex: number (1-4) - Gate index
    -- @param isDown: boolean - True to lower, false to raise
    -- @return: boolean - Success status
    if type(gateIndex) ~= 'number' or type(isDown) ~= 'boolean' then return false end
    TriggerClientEvent('bridge:gate:set', -1, gateIndex, isDown)
    return true
end)

exports('SetAllGates', function(isDown)
    -- Set all gates to same position
    -- @param isDown: boolean - True to lower all, false to raise all
    -- @return: boolean - Success status
    if type(isDown) ~= 'boolean' then return false end
    for i = 1, 4 do
        TriggerClientEvent('bridge:gate:set', -1, i, isDown)
    end
    return true
end)

-- Sequence control exports
exports('RunBridgeSequence', function(bridgeIndex, raiseDelta, lowerDelta, openSpeed, closeSpeed)
    -- Run full bridge sequence (raises, waits, lowers)
    -- @param bridgeIndex: number (1 or 2) - Bridge index
    -- @param raiseDelta: number (optional) - Amount to raise (default: 20.0)
    -- @param lowerDelta: number (optional) - Amount to lower (default: 20.0)
    -- @param openSpeed: number (optional) - Raise speed (default: 0.18)
    -- @param closeSpeed: number (optional) - Lower speed (default: 0.28)
    -- @return: boolean - Success status
    if type(bridgeIndex) ~= 'number' then return false end
    
    -- Check if sequence can start
    if not CanStartSequence() then
        return false
    end
    
    -- Trigger the sequence event (source will be 0 for server-side)
    TriggerEvent('bridge:RunSequence', bridgeIndex, raiseDelta, lowerDelta, openSpeed, closeSpeed)
    return true
end)

exports('CanRunSequence', function()
    -- Check if a sequence can be started
    -- @return: boolean - True if sequence can start
    return CanStartSequence()
end)

exports('IsSequenceRunning', function()
    -- Check if any sequence is currently running
    -- @return: boolean - True if sequence is active
    return IsSequenceActive()
end)

-- Traffic zone control exports
exports('EnableTrafficZones', function()
    -- Enable traffic speed zones (stops traffic)
    -- @return: boolean - Success status
    TriggerClientEvent('bridge:traffic:zones', -1, 'enable')
    return true
end)

exports('DisableTrafficZones', function()
    -- Disable traffic speed zones
    -- @return: boolean - Success status
    TriggerClientEvent('bridge:traffic:zones', -1, 'disable')
    return true
end)

-- State management exports (re-exported for convenience)
exports('GetBridgeState', GetBridgeState)
exports('SetBridgeState', SetBridgeState)
exports('GetLightState', GetLightState)
exports('SetLightState', SetLightState)
exports('SetAllLightStates', SetAllLightStates)

