-- client/cl_movebridge.lua
-- Server-driven bridge motion with minimum-jerk (S-curve) easing and strict entity resolution.
-- Includes LOD suppression so the static bridge LOD doesn't ghost while the live leaf moves.

-- ==============================
-- Tuning
-- ==============================
local DEFAULT_SPEED_UP   = 0.20   -- m/s nominal raise speed
local DEFAULT_SPEED_DOWN = 0.26   -- m/s nominal lower speed
local MIN_TRAVEL_TIME    = 1.35   -- seconds (floor for short moves)
local ENDSET_TOLERANCE   = 0.001  -- snap threshold in meters

-- Min/max offsets from base Z for each bridge; adjust if your map differs
local minOffset = { 6.8100, 8.2384 }
local maxOffset = { 40.0,    40.0  }

-- ==============================
-- Config / Bases
-- ==============================
local bases = {
  Config and Config.Bridge1Position or nil,
  Config and Config.Bridge2Position or nil,
}

-- Known high-detail models (replace if your map uses different drawbridge props)
local models = {
  [1] = joaat('car_drawbridge'),
  [2] = joaat('train_drawbridge'),
}

-- Probable LOD variants shipped in ymaps (extend if needed)
local LOD_MODELS = {
  joaat('car_drawbridge_lod'),
  joaat('car_drawbridge_slod'),
  joaat('train_drawbridge_lod'),
  joaat('train_drawbridge_slod'),
  joaat('drawbridge_lod'),
  joaat('drawbridge_slod'),
}

-- Precompute absolute Z bounds
local minAbsZ = {
  (bases[1] and bases[1].z or 0.0) + minOffset[1],
  (bases[2] and bases[2].z or 0.0) + minOffset[2],
}
local maxAbsZ = {
  (bases[1] and bases[1].z or 0.0) + maxOffset[1],
  (bases[2] and bases[2].z or 0.0) + maxOffset[2],
}

local function clamp(v,a,b) if v<a then return a elseif v>b then return b end; return v end

-- ==============================
-- LOD Suppression
-- ==============================
local function suppressLODsAt(pos, radius)
  if not pos then return end
  local r = radius or 120.0
  local r2 = r * r

  -- Hide known LOD models in this area (even if not yet spawned)
  for _, h in ipairs(LOD_MODELS) do
    CreateModelHide(pos.x, pos.y, pos.z, r, h, true)
  end

  -- Sweep currently spawned objects and hide ones that match
  local handle, obj = FindFirstObject()
  local success = true
  repeat
    if DoesEntityExist(obj) then
      local m = GetEntityModel(obj)
      for _, h in ipairs(LOD_MODELS) do
        if m == h then
          local ox, oy, oz = table.unpack(GetEntityCoords(obj))
          local dx, dy, dz = ox - pos.x, oy - pos.y, oz - pos.z
          if (dx*dx + dy*dy + dz*dz) <= r2 then
            SetEntityVisible(obj, false, false)
            SetEntityLodDist(obj, 0)
            -- If you prefer hard deletion, uncomment:
            -- SetEntityAsMissionEntity(obj, true, true)
            -- DeleteEntity(obj)
          end
        end
      end
    end
    success, obj = FindNextObject(handle)
  until not success
  EndFindObject(handle)
end

-- Proactively hide LODs at startup
Citizen.CreateThread(function()
  if bases[1] then suppressLODsAt(bases[1], 120.0) end
  if bases[2] then suppressLODsAt(bases[2], 120.0) end
end)

-- ==============================
-- Entity Resolution (strict)
-- ==============================
local ents = { nil, nil }

local function resolve(i)
  if ents[i] and DoesEntityExist(ents[i]) then return ents[i] end
  local base  = bases[i]
  local model = models[i]
  if not base or not model or model == 0 then return nil end

  -- Ensure LODs are culled before we lock onto the live leaf
  suppressLODsAt(base, 120.0)

  -- Only find the high-detail, correct model
  local ent = GetClosestObjectOfType(base.x, base.y, base.z, 100.0, model, false, false, false)
  if ent and ent ~= 0 and DoesEntityExist(ent) then
    ents[i] = ent
    -- Keep high-detail entity rendering at range and avoid LOD swaps
    SetEntityLodDist(ent, 32767)
    return ent
  end
  return nil
end

-- Debug: scan for entities and print info
RegisterCommand("bridgeScan", function()
  for i=1,2 do
    local base = bases[i]
    if not base then
      print(("Bridge %d base is nil"):format(i))
    else
      local e = resolve(i)
      if e then
        local m = GetEntityModel(e)
        local c = GetEntityCoords(e)
        print(("[bridgeScan] #%d entity %d, model %s, coords (%.3f, %.3f, %.3f)")
          :format(i, e, tostring(m), c.x, c.y, c.z))
      else
        print(("[bridgeScan] #%d not found near (%.2f, %.2f, %.2f)")
          :format(i, base.x, base.y, base.z))
      end
    end
  end
end, false)

-- Re-apply culling on demand (if mapper IPLs reload)
RegisterCommand("bridgeCull", function()
  if bases[1] then suppressLODsAt(bases[1], 120.0) end
  if bases[2] then suppressLODsAt(bases[2], 120.0) end
  print('[bridge] LOD suppression reapplied.')
end, false)

-- ==============================
-- Motion (minimum-jerk S-curve)
-- ==============================
local function minJerk01(t)
  if t <= 0.0 then return 0.0 end
  if t >= 1.0 then return 1.0 end
  local t2 = t * t
  local t3 = t2 * t
  local t4 = t3 * t
  local t5 = t4 * t
  return 10.0*t3 - 15.0*t4 + 6.0*t5
end

local function animateTo(ent, targetAbsZ, speedMps)
  local x, y, z0 = table.unpack(GetEntityCoords(ent))
  local dz   = (targetAbsZ or z0) - z0
  local dist = math.abs(dz)
  if dist < ENDSET_TOLERANCE then
    SetEntityCoordsNoOffset(ent, x, y, targetAbsZ, false, false, false)
    return
  end

  local goingUp  = dz > 0
  local baseSpd  = tonumber(speedMps)
  if not baseSpd or baseSpd <= 0 then
    baseSpd = goingUp and DEFAULT_SPEED_UP or DEFAULT_SPEED_DOWN
  end

  local dur = math.max(dist / baseSpd, MIN_TRAVEL_TIME)
  local t0  = GetGameTimer()

  while true do
    if not DoesEntityExist(ent) then return end
    local t = (GetGameTimer() - t0) / (dur * 1000.0)
    if t >= 1.0 then
      SetEntityCoordsNoOffset(ent, x, y, targetAbsZ, false, false, false)
      break
    end
    local s = minJerk01(t)
    local z = z0 + dz * s
    SetEntityCoordsNoOffset(ent, x, y, z, false, false, false)
    Wait(0)
  end
end

-- ==============================
-- Networking
-- ==============================
-- Track current bridge positions for sync validation
local currentBridgeZ = { nil, nil }

RegisterNetEvent('bridge:setHeight')
AddEventHandler('bridge:setHeight', function(index, absZ, speedMps)
  if type(index) ~= "number" or type(absZ) ~= "number" then return end
  if index < 1 or index > 2 then return end
  
  local ent = resolve(index)
  local target = clamp(absZ, minAbsZ[index], maxAbsZ[index])
  
  -- Update tracked position
  currentBridgeZ[index] = target
  
  if not ent then
    -- entity might not be streamed yet; retry with exponential backoff
    local retries = 0
    local maxRetries = 5
    
    local function retryResolve()
      retries = retries + 1
      local e2 = resolve(index)
      if e2 then
        animateTo(e2, target, speedMps)
      elseif retries < maxRetries then
        SetTimeout(800 * retries, retryResolve)
      else
        print(('[bridge] Failed to resolve bridge %d entity after %d retries'):format(index, maxRetries))
      end
    end
    
    SetTimeout(800, retryResolve)
    return
  end
  
  animateTo(ent, target, speedMps)
end)

-- Sync validation - periodically verify bridge position matches server
Citizen.CreateThread(function()
  while true do
    Wait(5000) -- Check every 5 seconds
    
    for i = 1, 2 do
      local ent = resolve(i)
      if ent and DoesEntityExist(ent) and currentBridgeZ[i] then
        local x, y, z = table.unpack(GetEntityCoords(ent))
        local diff = math.abs(z - currentBridgeZ[i])
        
        -- If position differs significantly, resync
        if diff > 0.5 then
          print(('[bridge] Position desync detected for bridge %d, resyncing...'):format(i))
          TriggerServerEvent('bridge:requestSync', i)
        end
      end
    end
  end
end)

RegisterNetEvent('bridge:spawnBridge')
AddEventHandler('bridge:spawnBridge', function()
  -- No-op: resolution is lazy in setHeight. Still, ensure LODs are hidden.
  if bases[1] then suppressLODsAt(bases[1], 120.0) end
  if bases[2] then suppressLODsAt(bases[2], 120.0) end
end)

-- ==============================
-- Commands (client -> server proxy)
-- ==============================
RegisterCommand("bridgeUp", function(_, args)
  local index  = tonumber(args[1]) or 1
  local amount = tonumber(args[2]) or 1.0
  local speed  = tonumber(args[3])
  TriggerServerEvent('bridge:serverMove', index, math.abs(amount), speed)
end, false)

RegisterCommand("bridgeDown", function(_, args)
  local index  = tonumber(args[1]) or 1
  local amount = tonumber(args[2]) or 1.0
  local speed  = tonumber(args[3])
  TriggerServerEvent('bridge:serverMove', index, -math.abs(amount), speed)
end, false)

-- ==============================
-- Exports (proxy to server)
-- ==============================
exports('MoveBridgeUp', function(index, amount, speed)
  TriggerServerEvent('bridge:serverMove', tonumber(index) or 1, math.abs(tonumber(amount) or 1.0), tonumber(speed))
end)

exports('MoveBridgeDown', function(index, amount, speed)
  TriggerServerEvent('bridge:serverMove', tonumber(index) or 1, -math.abs(tonumber(amount) or 1.0), tonumber(speed))
end)
