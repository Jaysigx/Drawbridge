-- client/cl_bridgegates.lua
-- Bridge barrier gate animation. Server-authoritative sync supported.

local function round(n) return n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5) end

local gateData = {
    { model = 'prop_bridge_barrier_gate_01x', targetVector = vector3(364.69915771484377, -2343.686279296875, 11.39140605926513), minRotationY = -90, maxRotationY =  90, rotationX = 0   },
    { model = 'prop_bridge_barrier_gate_01x', targetVector = vector3(342.0478515625,     -2343.5517578125,  11.46424674987793),  minRotationY =  90, maxRotationY = -90, rotationX = 180 },
    { model = 'prop_bridge_barrier_gate_01x', targetVector = vector3(364.7115478515625,  -2288.304443359375,11.36281585693359),  minRotationY = -90, maxRotationY =  90, rotationX = 0   },
    { model = 'prop_bridge_barrier_gate_01x', targetVector = vector3(342.1158447265625,  -2288.013671875,   11.30535125732421),  minRotationY =  90, maxRotationY = -90, rotationX = 180 },
}

local function resolveGateEntity(gateIndex)
    local g = gateData[gateIndex]
    if not g then return 0 end
    return GetClosestObjectOfType(g.targetVector.x, g.targetVector.y, g.targetVector.z, 2.0, g.model, false, false, false)
end

-- Smooth rotation around Y to a target relative Y offset from current
local function rotateGate(entity, currentRot, targetRot)
    Citizen.CreateThread(function()
        local step = (currentRot.y < targetRot.y) and 1 or -1
        for y = round(currentRot.y), round(targetRot.y), step do
            SetEntityRotation(entity, vector3(currentRot.x, y, currentRot.z), 1, true) -- 1 = world space
            Wait(10)
        end
    end)
end

-- isLowering=true => move toward minRotationY; false => toward maxRotationY
function MoveGate(gateIndex, isLowering)
    local g = gateData[gateIndex]
    if not g then return end

    local entity = resolveGateEntity(gateIndex)
    if entity == 0 or not DoesEntityExist(entity) then
        print(("Gate %d entity not found."):format(gateIndex))
        return
    end

    local cur = GetEntityRotation(entity, 1)
    local deltaY = isLowering and g.minRotationY or g.maxRotationY
    local target = vector3(cur.x, cur.y + deltaY, cur.z)
    rotateGate(entity, cur, target)
end

function MoveGates(_, isLowering)
    for i = 1, #gateData do MoveGate(i, isLowering) end
end

-- ===== Commands (optional) =====
if Config.Commands then
    RegisterCommand("gate", function(_, args)
        local idx = tonumber(args[1])
        local dir = args[2]
        if idx and dir then MoveGate(idx, dir == "down") end
    end, false)

    RegisterCommand("gateall", function(_, args)
        local dir = args[1]
        if dir then MoveGates(nil, dir == "down") end
    end, false)
end

-- ===== Exports =====
exports('MoveGate', MoveGate)
exports('MoveGates', MoveGates)
exports('RaiseLowerGateByIndex', function(gateIndex, isLowering) MoveGate(gateIndex, isLowering) end)

-- ===== Server -> Client sync events =====
RegisterNetEvent('bridge:gate:set')
AddEventHandler('bridge:gate:set', function(gateIndex, isDown)
    MoveGate(tonumber(gateIndex) or 1, isDown and true or false)
end)

RegisterNetEvent('bridge:gates:setAll')
AddEventHandler('bridge:gates:setAll', function(isDown)
    for i = 1, #gateData do MoveGate(i, isDown and true or false) end
end)

-- ===== Lifecycle helpers =====
local function resetGates()
    for i = 1, #gateData do
        -- best-effort raise on stop
        MoveGate(i, false)
    end
end

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        resetGates()
    end
end)

-- Optional banner
Citizen.CreateThread(function()
    print('Bridge Gates client loaded.')
end)
