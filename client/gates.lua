RegisterCommand("gate", function()
    Citizen.CreateThread(function()
        local gateData = {
            { modelHash = -1767084710, targetVector = vector3(364.9, -2343.92, 10.9),   targetRotationY = -90, minRotationY = -90, maxRotationY = 0 }, -- Gate 1
            { modelHash = -1767084710, targetVector = vector3(342.08, -2343.91, 11.22), targetRotationY = 90, minRotationY = 0, maxRotationY = 90 }, -- Gate 2
            { modelHash = -1767084710, targetVector = vector3(342.18, -2287.83, 11.21), targetRotationY = 90, minRotationY = 0, maxRotationY = 90 }, -- Gate 3
            { modelHash = -1767084710, targetVector = vector3(365.03, -2287.84, 10.84), targetRotationY = -90, minRotationY = -90, maxRotationY = 0 }  -- Gate 4
        }

        local transitionDuration = 5000 -- Transition duration in milliseconds

        for _, gate in ipairs(gateData) do
            Citizen.CreateThread(function()
                local foundObjects = GetGamePool('CObject')

                for _, object in ipairs(foundObjects) do
                    local objectModel = GetEntityModel(object)
                    local objectCoords = GetEntityCoords(object)
                    local distance = #(objectCoords - gate.targetVector)

                    if objectModel == gate.modelHash and distance <= 40.0 then

                        FreezeEntityPosition(bridgeObject, true)
                        SetEntityInvincible(bridgeObject, true)
                        local currentRotation = GetEntityRotation(object)
                        local startRotation = vector3(currentRotation.x, currentRotation.y, currentRotation.z)
                        local targetRotation = vector3(currentRotation.x, gate.targetRotationY, currentRotation.z)
                        local startTime = GetGameTimer()

                        while true do
                            Citizen.Wait(0)
                            local currentTime = GetGameTimer()
                            local elapsedTime = currentTime - startTime

                            local progress = elapsedTime / transitionDuration
                            if progress > 1.0 then
                                progress = 1.0
                            end

                            
                            function LerpVector(start, target, amount)
                                return vector3(
                                    start.x + (target.x - start.x) * amount,
                                    start.y + (target.y - start.y) * amount,
                                    start.z + (target.z - start.z) * amount
                                )
                            end

                            local lerpedRotation = LerpVector(startRotation, targetRotation, progress)
                            SetEntityRotation(object, lerpedRotation, 1, true)

                            if progress == 1.0 then
                                break
                            end
                        end
                    end
                end
            end)
        end
    end)
end)




