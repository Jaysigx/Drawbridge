-- server/sv_state.lua
-- Enhanced state management with persistence and validation

local State = {
    bridges = {
        [1] = { z = nil, moving = false, targetZ = nil },
        [2] = { z = nil, moving = false, targetZ = nil },
    },
    lights = {},
    gates = {},
    sequences = {
        active = {},
        count = 0,
    },
    initialized = false,
}

local function SaveState()
    if not Config or not Config.StatePersistence or not Config.StatePersistence.Enabled then return end
    
    local data = {
        bridges = {},
        lights = State.lights,
        timestamp = os.time(),
    }
    
    for i = 1, 2 do
        data.bridges[i] = {
            z = State.bridges[i].z,
        }
    end
    
    SaveResourceFile(GetCurrentResourceName(), 'state.json', json.encode(data), -1)
end

local function LoadState()
    if not Config or not Config.StatePersistence or not Config.StatePersistence.Enabled then return end
    
    local data = LoadResourceFile(GetCurrentResourceName(), 'state.json')
    if data then
        local saved = json.decode(data)
        if saved and saved.bridges then
            for i = 1, 2 do
                if saved.bridges[i] and saved.bridges[i].z then
                    State.bridges[i].z = saved.bridges[i].z
                end
            end
            if saved.lights then
                State.lights = saved.lights
            end
        end
    end
end

function GetBridgeState(index)
    return State.bridges[index]
end

function SetBridgeState(index, z, moving, targetZ)
    if index < 1 or index > 2 then return false end
    
    State.bridges[index].z = z
    State.bridges[index].moving = moving or false
    State.bridges[index].targetZ = targetZ
    
    if Config and Config.StatePersistence and Config.StatePersistence.Enabled then
        SaveState()
    end
    
    return true
end

function GetLightState(index)
    return State.lights[index]
end

function SetLightState(index, state)
    State.lights[index] = state
    if Config and Config.StatePersistence and Config.StatePersistence.Enabled then
        SaveState()
    end
end

function SetAllLightStates(states)
    State.lights = states or {}
    if Config and Config.StatePersistence and Config.StatePersistence.Enabled then
        SaveState()
    end
end

function CanStartSequence()
    if not Config or not Config.Sequence or not Config.Sequence.LockDuringSequence then return true end
    return State.sequences.count < (Config.Sequence.MaxConcurrentSequences or 1)
end

function RegisterSequence(id)
    if not CanStartSequence() then return false end
    State.sequences.active[id] = true
    State.sequences.count = State.sequences.count + 1
    return true
end

function UnregisterSequence(id)
    if State.sequences.active[id] then
        State.sequences.active[id] = nil
        State.sequences.count = math.max(0, State.sequences.count - 1)
    end
end

function IsSequenceActive()
    return State.sequences.count > 0
end

function InitializeState()
    if State.initialized then return end
    
    LoadState()
    
    -- Initialize bridge states from config if not loaded
    local bridgeBaseZ = {
        Config.Bridge1Position and Config.Bridge1Position.z or 0.0,
        Config.Bridge2Position and Config.Bridge2Position.z or 0.0,
    }
    local minHeights = { 6.8100, 8.2384 }
    
    for i = 1, 2 do
        if not State.bridges[i].z then
            State.bridges[i].z = bridgeBaseZ[i] + minHeights[i]
        end
    end
    
    State.initialized = true
end

-- Auto-save timer
Citizen.CreateThread(function()
    while true do
        Wait(1000) -- Check every second if persistence is enabled
        if Config and Config.StatePersistence and Config.StatePersistence.Enabled then
            Wait(Config.StatePersistence.SaveInterval or 30000)
            SaveState()
        else
            Wait(5000) -- Check again in 5 seconds if not enabled
        end
    end
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        InitializeState()
    end
end)

-- Export functions
exports('GetBridgeState', GetBridgeState)
exports('SetBridgeState', SetBridgeState)
exports('GetLightState', GetLightState)
exports('SetLightState', SetLightState)
exports('SetAllLightStates', SetAllLightStates)
exports('CanStartSequence', CanStartSequence)
exports('RegisterSequence', RegisterSequence)
exports('UnregisterSequence', UnregisterSequence)
exports('IsSequenceActive', IsSequenceActive)

