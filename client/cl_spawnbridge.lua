local bridgeObjects = {}
local initialBridgePositions = {Config.Bridge1Position, Config.Bridge2Position}
local models = {joaat('car_drawbridge'), joaat('train_drawbridge')}
local isBridgeCreated = {false, false}
local bridgeEntities = {nil, nil}

-- Function to load models
function LoadModel(modelIndex)
    local model = models[modelIndex]

    if not HasModelLoaded(model) then
        RequestModel(model)
        Citizen.Wait(100)
        while not HasModelLoaded(model) do
            Citizen.Wait(100)
        end
        print("Model loaded successfully: " .. model)
    end
end

-- Function to create bridge objects
function CreateBridgeObject(index)
    local model = models[index]
    local initialBridgePosition = initialBridgePositions[index]

    LoadModel(index)

    if not isBridgeCreated[index] or not DoesEntityExist(bridgeEntities[index]) then
        if bridgeEntities[index] and DoesEntityExist(bridgeEntities[index]) then
            DeleteEntity(bridgeEntities[index])
        end

        bridgeEntities[index] = CreateObject(model, initialBridgePosition.x, initialBridgePosition.y, initialBridgePosition.z, true, true, false)

        if bridgeEntities[index] and bridgeEntities[index] ~= 0 then
            SetEntityLodDist(bridgeEntities[index], 500)
            SetEntityAsMissionEntity(bridgeEntities[index], true, true)
            FreezeEntityPosition(bridgeEntities[index], true)
            SetEntityInvincible(bridgeEntities[index], true)
            isBridgeCreated[index] = true
            table.insert(bridgeObjects, bridgeEntities[index])
        else
            print("Failed to create Bridge object. Model may be invalid or position is obstructed.")
        end
    else
        print("Bridge object already exists.")
    end
end

-- Function to check and update bridge objects
function CreateOrUpdateBridgeObjects()
    for index, _ in ipairs(initialBridgePositions) do
        if not isBridgeCreated[index] or not DoesEntityExist(bridgeEntities[index]) then
            CreateBridgeObject(index)
            return
        end
    end
end

-- Thread to manage initial bridge objects creation/update
Citizen.CreateThread(function()
    for index, _ in ipairs(initialBridgePositions) do
        CreateOrUpdateBridgeObjects()
    end

    while true do
        Citizen.Wait(5000)

        for index, model in ipairs(models) do
            if HasModelLoaded(model) then
                print("Bridge " .. index .. " Loaded")
            else
                print("Bridge " .. index .. " Model is still loading...")
            end
        end
    end
end)

-- Function to count existing bridges near a position
function CountExistingBridgesNearPosition(position)
    local count = 0
    for _, bridgeEntity in pairs(bridgeEntities) do
        if bridgeEntity and DoesEntityExist(bridgeEntity) then
            local distance = #(GetEntityCoords(bridgeEntity) - position)
            if distance < 250.0 then
                count = count + 1
            end
        end
    end
    return count
end

-- Function to spawn bridge if not exists near player
function SpawnBridgeIfNotExists(index)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - initialBridgePositions[index])

            if distance < 250.0 then
                local existingBridgesNearPlayer = CountExistingBridgesNearPosition(initialBridgePositions[index])

                if existingBridgesNearPlayer < 1 then
                    if not isBridgeCreated[index] then
                        CreateBridgeObject(index)
                    end
                end
            elseif isBridgeCreated[index] then
                DeleteEntity(bridgeEntities[index])
                bridgeEntities[index] = nil
                isBridgeCreated[index] = false
            end
        end
    end)
end

-- Thread to check and spawn bridge objects near players
Citizen.CreateThread(function()
    for index, _ in ipairs(initialBridgePositions) do
        SpawnBridgeIfNotExists(index)
    end
end)


-- Event handler for resource start - creates bridges on resource start
AddEventHandler('onResourceStart', function()
    for index, _ in ipairs(initialBridgePositions) do
        CreateBridgeObject(index)
    end
end)

-- Network event to spawn bridges - to sync bridge objects among players
RegisterNetEvent('PE-Bridge:spawnBridge')
AddEventHandler('PE-Bridge:spawnBridge', function()
    for index, _ in ipairs(initialBridgePositions) do
        CreateBridgeObject(index)
        CreateOrUpdateBridgeObjects(index)
    end
end)

-- Event handler for resource stop - cleans up bridges on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, bridgeObject in pairs(bridgeObjects) do
            if DoesEntityExist(bridgeObject) then
                SetEntityAsMissionEntity(bridgeObject, false, true)
                DeleteObject(bridgeObject)
            end
        end
    end
end)
