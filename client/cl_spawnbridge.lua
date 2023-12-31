local bridgeObjects = {}
local initialBridgePositions = {Config.Bridge1Position, Config.Bridge2Position}
local models = {joaat('car_drawbridge'), joaat('train_drawbridge')}
local isBridgeCreated = {car = false, train = false}
local bridgeEntities = {car = nil, train = nil}

function LoadModels()
    for _, model in ipairs(models) do
        if not HasModelLoaded(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(100)
            end
            print("Model loaded successfully: " .. model)
        end
    end
end

function CreateBridgeObject(index)
    local model = models[index]
    local initialBridgePosition = initialBridgePositions[index]

    LoadModels()

    if not isBridgeCreated[index] or not DoesEntityExist(bridgeEntities[index]) then
        if bridgeEntities[index] and DoesEntityExist(bridgeEntities[index]) then
            DeleteEntity(bridgeEntities[index])
        end

        bridgeEntities[index] = CreateObject(model, initialBridgePosition.x, initialBridgePosition.y, initialBridgePosition.z, true, true, false)

        if bridgeEntities[index] and bridgeEntities[index] ~= 0 then
            SetEntityLodDist(bridgeEntities[index], 250)
            SetEntityAsMissionEntity(bridgeEntities[index], true, true)
            FreezeEntityPosition(bridgeEntities[index], true)
            SetEntityInvincible(bridgeEntities[index], true)
            isBridgeCreated[index] = true
            table.insert(bridgeObjects, bridgeEntities[index])
        else
            print("Failed to create Bridge object. Model may be invalid or position is obstructed.")
        end
    end
end

-- Function to create or update bridge objects
function CreateOrUpdateBridgeObjects()
    for index, _ in ipairs(initialBridgePositions) do
        if not isBridgeCreated[index] or not DoesEntityExist(bridgeEntities[index]) then
            CreateBridgeObject(index)
            return
        end
    end
end


-- Function to count existing bridges near a position
function CountExistingCarAndTrainBridgesNearPosition(position)
    local countCar = 0
    local countTrain = 0
    for _, bridgeEntity in pairs(bridgeEntities) do
        if bridgeEntity and DoesEntityExist(bridgeEntity) then
            local distance = #(GetEntityCoords(bridgeEntity) - position)
            if distance < 250.0 then
                if bridgeEntity == bridgeEntities.car then
                    countCar = countCar + 1
                elseif bridgeEntity == bridgeEntities.train then
                    countTrain = countTrain + 1
                end
            end
        end
    end
    return countCar, countTrain
end

-- Function to manage bridge spawning based on player proximity
function SpawnCarOrTrainBridgeIfNotExists(index)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(500)

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - initialBridgePositions[index])

            if distance < 250.0 then
                local existingCar, existingTrain = CountExistingCarAndTrainBridgesNearPosition(initialBridgePositions[index])

                if existingCar < 1 and not isBridgeCreated.car then
                    CreateBridgeObject(1)
                end

                if existingTrain < 1 and not isBridgeCreated.train then
                    CreateBridgeObject(2)
                end
            else
                if index == 1 and isBridgeCreated.car then
                    DeleteEntity(bridgeEntities.car)
                    bridgeEntities.car = nil
                    isBridgeCreated.car = false
                elseif index == 2 and isBridgeCreated.train then
                    DeleteEntity(bridgeEntities.train)
                    bridgeEntities.train = nil
                    isBridgeCreated.train = false
                end
            end
        end
    end)
end

-- Thread to check and spawn bridge objects near players
Citizen.CreateThread(function()
    for index, _ in ipairs(initialBridgePositions) do
        SpawnCarOrTrainBridgeIfNotExists(index)
    end
end)

-- Event handler for resource start - creates bridges on resource start
AddEventHandler('onResourceStart', function()
    for index, _ in ipairs(initialBridgePositions) do
        CreateBridgeObject(index)
    end
end)

-- Network event to spawn bridges - to sync bridge objects among players
RegisterNetEvent('bridge:spawnBridge')
AddEventHandler('bridge:spawnBridge', function()
    for index, _ in ipairs(initialBridgePositions) do
        CreateBridgeObject(index)
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
