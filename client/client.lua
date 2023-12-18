local bridgeObject = nil
local initialBridgePosition = Config.Bridge1Position
local targetBridgeHeight = initialBridgePosition.z
local bridgeMovementSpeed = 0.009
local maxBridgeHeight = initialBridgePosition.z + 30.0
local minBridgeHeight = initialBridgePosition.z
local model = GetHashKey('car_drawbridge')

local isBridgeCreated = false



function LoadModel()
    local modelRequested = false

    while not HasModelLoaded(model) do
        if not modelRequested then
            modelRequested = true
            RequestModel(model)
            print("Requested model: " .. model)
        end
        Citizen.Wait(5000)
        print("Model loading: " .. tostring(IsModelInCdimage(model)), "Model loaded: " .. tostring(HasModelLoaded(model)))
    end

    print("Model loaded successfully: " .. model)
end



function CreateBridgeObject()
    LoadModel()

    if not HasModelLoaded(model) then
        print("Model not loaded. Ensure the correct model is used or position is obstructed.")
        return
    end

    if bridgeObject and DoesEntityExist(bridgeObject) then
        DeleteEntity(bridgeObject)
    end

    bridgeObject = CreateObject(model, initialBridgePosition.x, initialBridgePosition.y, initialBridgePosition.z, true, true, false)

    if bridgeObject and bridgeObject ~= 0 then
        SetEntityLodDist(bridgeObject, 500)
        SetEntityAsMissionEntity(bridgeObject, true, true)
        FreezeEntityPosition(bridgeObject, true)
        SetEntityInvincible(bridgeObject, true)
        isBridgeCreated = true
    else
        print("Failed to create the bridge object. Model may be invalid or position is obstructed.")
    end
end



function CreateOrUpdateBridgeObject()
    if not isBridgeCreated then
        CreateBridgeObject()
    else
        if not DoesEntityExist(bridgeObject) then
            CreateBridgeObject()
        end
    end
end



Citizen.CreateThread(function()
    while true do
        CreateOrUpdateBridgeObject()
        Citizen.Wait(5000) -- Adjust the delay as needed

        if HasModelLoaded(model) then
            print("Car Bridge Loaded")
        else
            print("Car Bridge Model is still loading...")
        end
    end
end)



Citizen.CreateThread(function()
    CreateBridgeObject()
    TriggerServerEvent('PE-Bridge:SyncInitialPosition', initialBridgePosition)
end)

if bridgeObject and bridgeObject ~= 0 then
    -- ...
else
    print("Failed to create the bridge object.")
    if not HasModelLoaded(model) then
        print("Model not loaded. Ensure the model is correct and loaded.")
    else
        print("Failed to create the object. Check if the position is obstructed or invalid.")
    end
end



local isBridgeSpawned = false

function SpawnBridgeIfNotExists()
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()

        while true do
            Citizen.Wait(1000)

            local playerCoords = GetEntityCoords(playerPed)

            if playerCoords then
                local distance = #(playerCoords - initialBridgePosition)

                if distance < 250.0 then
                    if not isBridgeSpawned then
                        if not HasModelLoaded(model) then
                            LoadModel()
                            while not HasModelLoaded(model) do
                                Citizen.Wait(100)
                            end
                        end
                        CreateBridgeObject()
                        isBridgeSpawned = true
                    end
                elseif isBridgeSpawned then
                    DeleteEntity(bridgeObject)
                    bridgeObject = nil
                    isBridgeSpawned = false
                end
            else
                print("Player coordinates are nil.")
            end
        end
    end)
end



Citizen.CreateThread(function()
    CreateBridgeObject()
    TriggerServerEvent('PE-Bridge:SyncInitialPosition', initialBridgePosition)
end)

AddEventHandler('playerSpawned', CreateBridgeObject)
AddEventHandler('onResourceStart', CreateBridgeObject)


function adjustBridgeHeight(amount)
    TriggerServerEvent('PE-Bridge:AdjustBridgeHeight', amount)
end



Citizen.CreateThread(function()
    CreateBridgeObject()
end)



RegisterNetEvent('PE-Bridge:spawnBridge')
AddEventHandler('PE-Bridge:spawnBridge', function()
    CreateBridgeObject()
end)



RegisterCommand("bridge", function()
    CreateBridgeObject()
end, false)



RegisterCommand("raiseBridge", function()
    adjustBridgeHeight(10.0)
end, false)



RegisterCommand("lowerBridge", function()
    adjustBridgeHeight(-20.0)
end, false)



function Lerp(start, stop, t)
    return start + (stop - start) * t
end


-- Handling bridge movement
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if bridgeObject and targetBridgeHeight ~= 0 then
            local currentPos = GetEntityCoords(bridgeObject)
            local targetPos = vector3(currentPos.x, currentPos.y, initialBridgePosition.z + targetBridgeHeight)
            local distance = Vdist(currentPos, targetPos)
            local duration = (distance / bridgeMovementSpeed) * 10

            if duration > 0 then
                local startTime = GetGameTimer()
                local endTime = startTime + duration

                while GetGameTimer() < endTime do
                    local elapsed = GetGameTimer() - startTime
                    local t = elapsed / duration
                    local newHeight = Lerp(currentPos.z, targetPos.z, t)
                    SetEntityCoordsNoOffset(bridgeObject, currentPos.x, currentPos.y, newHeight, true, true, true)
                    Citizen.Wait(0)
                end

                SetEntityCoordsNoOffset(bridgeObject, currentPos.x, currentPos.y, targetPos.z, true, true, true)

                if targetBridgeHeight >= maxBridgeHeight or targetBridgeHeight <= minBridgeHeight then
                    targetBridgeHeight = 0
                end
            end
        end
    end
end)



AddEventHandler('playerSpawned', function()
    CreateBridgeObject()
end)



AddEventHandler('onResourceStart', function(resourceName)
    CreateBridgeObject()
end)



AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for _, v in pairs(model) do
			SetEntityAsMissionEntity(v, false, true)
			DeleteObject(v)
		end
	end
end)
