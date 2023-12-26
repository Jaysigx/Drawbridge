local initialGatePositions = {}
local gateUpData = {
    { modelHash = joaat('prop_bridge_barrier_gate_01x'), targetVector = vector3(364.9, -2343.92, 10.9), targetRotationY = 90, minRotationY = -90, maxRotationY = 0 },
    { modelHash = joaat('prop_bridge_barrier_gate_01x'), targetVector = vector3(342.08, -2343.91, 11.22), targetRotationY = 90, minRotationY = -90, maxRotationY = 0 },
    { modelHash = joaat('prop_bridge_barrier_gate_01x'), targetVector = vector3(342.18, -2287.83, 11.21), targetRotationY = 90, minRotationY = -90, maxRotationY = 0 },
    { modelHash = joaat('prop_bridge_barrier_gate_01x'), targetVector = vector3(365.03, -2287.84, 10.84), targetRotationY = 90, minRotationY = -90, maxRotationY = 0 }
}

local gateDownData = {
    { modelHash = joaat('prop_bridge_barrier_gate_01x'), targetVector = vector3(364.9, -2343.92, 10.9), targetRotationY = -90, minRotationY = -90, maxRotationY = 0 },
    { modelHash = joaat('prop_bridge_barrier_gate_01x'), targetVector = vector3(342.08, -2343.91, 11.22), targetRotationY = -90, minRotationY = -90, maxRotationY = 0 },
    { modelHash = joaat('prop_bridge_barrier_gate_01x'), targetVector = vector3(342.18, -2287.83, 11.21), targetRotationY = -90, minRotationY = -90, maxRotationY = 0 },
    { modelHash = joaat('prop_bridge_barrier_gate_01x'), targetVector = vector3(365.03, -2287.84, 10.84), targetRotationY = -90, minRotationY = -90, maxRotationY = 0 }
}

function RotateGate(object, targetRotation)
    SetEntityRotation(object, targetRotation, 1, true)
end

function MoveGate(gateData, isLowering)
    local foundObjects = GetGamePool('CObject')

    for _, object in ipairs(foundObjects) do
        local objectModel = GetEntityModel(object)
        local objectCoords = GetEntityCoords(object)
        local distance = #(objectCoords - gateData.targetVector)

        if objectModel == gateData.modelHash and distance <= 80.0 then
            local currentRotation = GetEntityRotation(object)
            local targetRotationY = isLowering and gateData.minRotationY or gateData.maxRotationY
            local targetRotation = vector3(currentRotation.x, targetRotationY, currentRotation.z)

            RotateGate(object, targetRotation)
        end
    end
end

function MoveGates(gateArray, isLowering)
    for index, gateData in ipairs(gateArray) do
        MoveGate(gateData, isLowering)
    end
end

RegisterCommand("gate", function(source, args, rawCommand)
    local gateIndex = tonumber(args[1])
    local direction = args[2]

    if gateIndex and direction then
        local selectedGates = direction == "up" and gateUpData or gateDownData
        MoveGate(selectedGates[gateIndex], direction == "down")
    end
end, false)

RegisterCommand("gateall", function(source, args, rawCommand)
    local direction = args[1]

    if direction then
        local selectedGates = direction == "up" and gateUpData or gateDownData
        MoveGates(selectedGates, direction == "down")
    end
end, false)

-- Wrapper function to export
function RaiseLowerGateByIndex(gateIndex, isLowering)
    local selectedGates = isLowering and gateDownData or gateUpData
    MoveGate(selectedGates[gateIndex], isLowering)
end

-- Exports
exports('MoveGate', MoveGate)
exports('MoveGates', MoveGates)
exports('RaiseLowerGateByIndex', RaiseLowerGateByIndex)

function StartResource()
    print('gates are a sexy bunch')
end

function StopResource()
    for _, gateData in ipairs(gateUpData) do
        MoveGate(gateData, false) -- Reset gates to their initial positions
    end
end

-- Optional: Automatically reset gates when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        StopResource()
    end
end)

-- Call StartResource when the script starts
StartResource()
