local initialBridgePositions = {Config.Bridge1Position, Config.Bridge2Position}
local models = {GetHashKey('car_drawbridge'), GetHashKey('train_drawbridge')}
local bridgeEntities = {nil, nil}
local minBridgeHeights = {6.8100, 8.2384} -- Heights of the lowest points of the bridges
local maxBridgeHeight = 40 -- Maximum bridge height

-- Function to ensure the bridge entity exists at the initial position
function EnsureBridgeEntity(index)
    local model = models[index]
    local initialBridgePosition = initialBridgePositions[index]

    if not DoesEntityExist(bridgeEntities[index]) then
        local entity = GetClosestObjectOfType(initialBridgePosition.x, initialBridgePosition.y, initialBridgePosition.z, 5.0, model, false, false, false)
        if DoesEntityExist(entity) then
            bridgeEntities[index] = entity
        else
            print("Failed to ensure Bridge " .. index .. " entity.")
        end
    end
end

function ModelExistsAtIndex(index)
    return index >= 1 and index <= #models
end

-- Linear interpolation function
function Lerp(a, b, t)
    return a + (b - a) * t
end

-- Function to transition bridge height smoothly
function TransitionBridgeHeight(entity, targetHeight)
    local currentPosition = GetEntityCoords(entity)
    local distance = targetHeight - currentPosition.z
    local direction = distance > 0 and 1 or -1 -- Determine the direction
    local transitionSpeed = 0.009 -- Speed of the transition
    local transitionInterval = 5 -- Interval between steps

    local steps = math.ceil(math.abs(distance / transitionSpeed))

    for i = 1, steps do
        local t = i / steps
        local newHeight = Lerp(currentPosition.z, targetHeight, t)
        SetEntityCoords(entity, currentPosition.x, currentPosition.y, newHeight, true, true, true)
        Citizen.Wait(transitionInterval)
    end

    -- Ensure the bridge reaches exactly the target height
    SetEntityCoords(entity, currentPosition.x, currentPosition.y, targetHeight, true, true, true)
end

-- Listen for server-synced events to move the bridge up
RegisterNetEvent("bridge:moveUp")
AddEventHandler("bridge:moveUp", function(index, amount)
    -- Adjust the bridge height on the client side based on server data
    MoveBridgeUp(index, amount)
end)

-- Listen for server-synced events to move the bridge down
RegisterNetEvent("bridge:moveDown")
AddEventHandler("bridge:moveDown", function(index, amount)
    -- Adjust the bridge height on the client side based on server data
    MoveBridgeDown(index, amount)
end)

-- Function to move the bridge up based on server data
function MoveBridgeUp(index, amount)
    if bridgeEntities[index] and DoesEntityExist(bridgeEntities[index]) then
        local currentPosition = GetEntityCoords(bridgeEntities[index])
        local newHeight = math.min(currentPosition.z + amount, initialBridgePositions[index].z + maxBridgeHeight)
        TransitionBridgeHeight(bridgeEntities[index], newHeight)
        print("Moved Bridge " .. index .. " up by " .. amount .. " units.")
    else
        print("Bridge " .. index .. " entity does not exist.")
    end
end

-- Function to move the bridge down based on server data
function MoveBridgeDown(index, amount)
    if bridgeEntities[index] and DoesEntityExist(bridgeEntities[index]) then
        local currentPosition = GetEntityCoords(bridgeEntities[index])
        local newHeight = math.max(currentPosition.z - amount, initialBridgePositions[index].z + minBridgeHeights[index])
        TransitionBridgeHeight(bridgeEntities[index], newHeight)
        print("Moved Bridge " .. index .. " down by " .. amount .. " units.")
    else
        print("Bridge " .. index .. " entity does not exist.")
    end
end

-- Command to move the bridge up
RegisterCommand("bridgeUp", function(source, args, rawCommand)
    local index = tonumber(args[1]) or 1 -- Bridge index
    local amount = tonumber(args[2]) or 1.0 -- Amount to move

    if index >= 1 and index <= #models then
        if ModelExistsAtIndex(index) then
            EnsureBridgeEntity(index)
            MoveBridgeUp(index, amount)
        else
            print("Bridge " .. index .. " model does not exist.")
        end
    else
        print("Invalid bridge index.")
    end
end, false)

-- Command to move the bridge down
RegisterCommand("bridgeDown", function(source, args, rawCommand)
    local index = tonumber(args[1]) or 1 -- Bridge index
    local amount = tonumber(args[2]) or 1.0 -- Amount to move

    if index >= 1 and index <= #models then
        if ModelExistsAtIndex(index) then
            EnsureBridgeEntity(index)
            MoveBridgeDown(index, amount)
        else
            print("Bridge " .. index .. " model does not exist.")
        end
    else
        print("Invalid bridge index.")
    end
end, false)
