-- client/cl_exports.lua
-- Client-side exports for other resources to interact with the bridge system

-- Bridge movement exports (these proxy to server)
exports('MoveBridgeUp', function(index, amount, speed)
    -- Move bridge up (client-side proxy to server)
    -- @param index: number (1 or 2) - Bridge index
    -- @param amount: number - Amount to move up
    -- @param speed: number (optional) - Movement speed
    -- @return: boolean - Success status
    if type(index) ~= 'number' or type(amount) ~= 'number' then return false end
    TriggerServerEvent('bridge:serverMove', index, math.abs(amount), speed)
    return true
end)

exports('MoveBridgeDown', function(index, amount, speed)
    -- Move bridge down (client-side proxy to server)
    -- @param index: number (1 or 2) - Bridge index
    -- @param amount: number - Amount to move down
    -- @param speed: number (optional) - Movement speed
    -- @return: boolean - Success status
    if type(index) ~= 'number' or type(amount) ~= 'number' then return false end
    TriggerServerEvent('bridge:serverMove', index, -math.abs(amount), speed)
    return true
end)

-- Traffic lights export
exports('bridgelights', function(state)
    -- Set all traffic lights to state (client-side proxy to server)
    -- @param state: number - Light state (0=Green, 1=Red, 2=Yellow, 3=Reset)
    -- @return: boolean - Success status
    if type(state) ~= 'number' then return false end
    TriggerServerEvent('bridge:syncLights', {[1]=state, [2]=state, [3]=state, [4]=state, [5]=state, [6]=state, [7]=state, [8]=state})
    return true
end)

-- Gate exports (local client-side)
-- Note: MoveGate and MoveGates are defined in cl_bridgegates.lua
-- These exports are already registered there, but we document them here for clarity

