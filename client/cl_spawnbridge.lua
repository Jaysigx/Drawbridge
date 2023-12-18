local bridgeObjects = {}
local initialBridgePositions = {Config.Bridge1Position, Config.Bridge2Position}
local models = {GetHashKey('car_drawbridge'), GetHashKey('train_drawbridge')}
local isBridgeCreated = {false, false}
local bridgeEntities = {nil, nil}

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

function CreateBridgeObject(index)
    local model = models[index]
    local initialBridgePosition = initialBridgePositions[index]

    LoadModel(index)

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
end

function CreateOrUpdateBridgeObjects()
    for index, _ in ipairs(initialBridgePositions) do
        if not isBridgeCreated[index] or not DoesEntityExist(bridgeEntities[index]) then
            CreateBridgeObject(index)
            return
        end
    end
end

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

function SpawnBridgeIfNotExists(index)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - initialBridgePositions[index])

            if distance < 250.0 then
                if not isBridgeCreated[index] then
                    CreateBridgeObject(index)
                    return
                end
            elseif isBridgeCreated[index] then
                DeleteEntity(bridgeEntities[index])
                bridgeEntities[index] = nil
                isBridgeCreated[index] = false
            end
        end
    end)
end

Citizen.CreateThread(function()
    for index, _ in ipairs(initialBridgePositions) do
        SpawnBridgeIfNotExists(index)
    end
end)

AddEventHandler('playerSpawned', CreateOrUpdateBridgeObjects)
AddEventHandler('onResourceStart', function()
    for index, _ in ipairs(initialBridgePositions) do
        CreateBridgeObject(index)
    end
end)

RegisterNetEvent('PE-Bridge:spawnBridge')
AddEventHandler('PE-Bridge:spawnBridge', function()
    for index, _ in ipairs(initialBridgePositions) do
        CreateBridgeObject(index)
        CreateOrUpdateBridgeObjects(index)
    end
end)

RegisterCommand("bridge", function()
    for index, _ in ipairs(initialBridgePositions) do
        CreateBridgeObject(index)
    end
end, false)

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
