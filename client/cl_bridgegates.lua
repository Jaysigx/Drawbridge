local initialGatePositions = {}
local gateData = {
    { model = 'prop_bridge_barrier_gate_01x', targetVector = vector3(364.69915771484377, -2343.686279296875, 11.39140605926513), minRotationY = -90, maxRotationY = 90, rotationX = 0 },
    { model = 'prop_bridge_barrier_gate_01x', targetVector = vector3(342.0478515625,     -2343.5517578125,   11.46424674987793), minRotationY = 90, maxRotationY = -90, rotationX = 180 },
    { model = 'prop_bridge_barrier_gate_01x', targetVector = vector3(364.7115478515625,  -2288.304443359375, 11.36281585693359), minRotationY = -90, maxRotationY = 90, rotationX = 0 },
    { model = 'prop_bridge_barrier_gate_01x', targetVector = vector3(342.1158447265625,  -2288.013671875,    11.30535125732421), minRotationY = 90, maxRotationY = -90, rotationX = 180 }
}

function RotateGate(object, currentRotation, targetRotation)
    Citizen.CreateThread(function()
        for targetY = math.round(currentRotation.y), math.round(targetRotation.y), currentRotation.y < targetRotation.y and 1 or -1 do
            SetEntityRotation(object, vector3( currentRotation.x, targetY, currentRotation.z ), 1, true)
            Wait(10)
        end
    end)
end

function MoveGate(gateIndex, isLowering)
    local gate = gateData[gateIndex]
    local entity = GetClosestObjectOfType(gate.targetVector.x, gate.targetVector.y, gate.targetVector.z, 2.0, gate.model, false, false, false)
    local currentRotation = GetEntityRotation(entity)
    local targetRotationY = isLowering and gate.minRotationY or gate.maxRotationY
    local targetRotation = vector3(currentRotation.x, currentRotation.y + targetRotationY, currentRotation.z)
    RotateGate(entity, currentRotation, targetRotation)
end

function MoveGates(gateArray, isLowering)
    for gateIndex = 1, 4 do
        MoveGate(gateIndex, isLowering)
    end
end

if Config.Commands then
    RegisterCommand("gate", function(source, args, rawCommand)
        local gateIndex = tonumber(args[1])
        local direction = args[2]

        if gateIndex and direction then
            MoveGate(gateIndex, direction == "down")
        end
    end, false)

    RegisterCommand("gateall", function(source, args, rawCommand)
        local direction = args[1]

        if direction then
            for gateIndex = 1, 4 do
                MoveGate(gateIndex, direction == "down")
            end
        end
    end, false)
end

-- Wrapper function to export
function RaiseLowerGateByIndex(gateIndex, isLowering)
    MoveGate(gateIndex, isLowering)
end

-- Exports
exports('MoveGate', MoveGate)
exports('MoveGates', MoveGates)
exports('RaiseLowerGateByIndex', RaiseLowerGateByIndex)

function StartResource()
    print('Bridges 1.0 by Jaysigx loaded')
end

function StopResource()
    for gateIndex = 1, 4 do
        MoveGate(gateIndex, false) -- Reset gates to their initial positions
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