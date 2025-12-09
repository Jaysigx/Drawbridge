-- sv_main.lua
-- Enhanced server authoritative bridge logic with improved sync and validation

-- Load state management
local GetBridgeState = exports[GetCurrentResourceName()]:GetBridgeState
local SetBridgeState = exports[GetCurrentResourceName()]:SetBridgeState
local CanStartSequence = exports[GetCurrentResourceName()]:CanStartSequence
local RegisterSequence = exports[GetCurrentResourceName()]:RegisterSequence
local UnregisterSequence = exports[GetCurrentResourceName()]:UnregisterSequence
local IsSequenceActive = exports[GetCurrentResourceName()]:IsSequenceActive

-- Base Z from config
local bridgeBaseZ = {
  Config.Bridge1Position and Config.Bridge1Position.z or 0.0,
  Config.Bridge2Position and Config.Bridge2Position.z or 0.0
}

local minHeights = { 6.8100, 8.2384 }
local maxHeight  = 40.0

-- default speeds
local bridgeSpeed = { 0.20, 0.26 }

local function clamp(v,a,b) if v<a then return a elseif v>b then return b end; return v end

local function hasPermission(source, permission)
    if not Config or not Config.Permissions then return true end
    
    if not Config.Permissions[permission] or Config.Permissions[permission] == false then
        return true -- No permission required
    end
    
    if Config.Permissions.AdminOnly then
        return IsPlayerAceAllowed(source, "bridge.admin")
    end
    
    local perm = Config.Permissions[permission]
    if type(perm) == "string" and perm ~= "" then
        return IsPlayerAceAllowed(source, perm)
    end
    
    return true
end

local function getCurrentBridgeZ(index)
    local state = GetBridgeState(index)
    if state and state.z then
        return state.z
    end
    -- Fallback to default
    return bridgeBaseZ[index] + minHeights[index]
end

local function setHeight(index, absZ, notifyAll, speed, source)
  if index < 1 or index > 2 then return false end
  
  -- Validate state if enabled
  if Config and Config.Sync and Config.Sync.ValidateState then
    if IsSequenceActive() and Config.Sequence and Config.Sequence.LockDuringSequence then
      if source then
        TriggerClientEvent('bridge:notification', source, 'Bridge is locked during sequence', 'error')
      end
      return false
    end
  end
  
  local lo = bridgeBaseZ[index] + minHeights[index]
  local hi = bridgeBaseZ[index] + maxHeight
  absZ = clamp(absZ, lo, hi)
  
  local mps = (type(speed)=="number" and speed>0) and speed or bridgeSpeed[index]
  
  -- Update state
  SetBridgeState(index, absZ, true, absZ)
  
  -- Broadcast to clients
  TriggerClientEvent('bridge:setHeight', notifyAll and -1 or source, index, absZ, mps)
  
  -- Mark as not moving after a delay (client will handle actual movement)
  SetTimeout(100, function()
    SetBridgeState(index, absZ, false, nil)
  end)
  
  return true
end

RegisterNetEvent('bridge:serverMove', function(index, delta, speed)
  local source = source or 0
  
  -- Permission check (skip for server-side calls)
  if source > 0 and not hasPermission(source, 'UseCommands') then
    TriggerClientEvent('bridge:notification', source, 'You do not have permission to control the bridge', 'error')
    return
  end
  
  if type(index)~='number' or type(delta)~='number' then return end
  if index<1 or index>2 then return end
  
  local currentZ = getCurrentBridgeZ(index)
  local lo = bridgeBaseZ[index] + minHeights[index]
  local hi = bridgeBaseZ[index] + maxHeight
  local target = clamp(currentZ + delta, lo, hi)
  
  setHeight(index, target, true, speed, source)
end)

RegisterNetEvent('bridge:serverSet', function(index, absZ, speed)
  local source = source or 0
  
  -- Permission check (skip for server-side calls)
  if source > 0 and not hasPermission(source, 'UseCommands') then
    TriggerClientEvent('bridge:notification', source, 'You do not have permission to control the bridge', 'error')
    return
  end
  
  if type(index)~='number' or type(absZ)~='number' then return end
  if index<1 or index>2 then return end
  
  setHeight(index, absZ, true, speed, source)
end)

-- Enhanced spawn and sync
RegisterServerEvent('syncBridgeSpawn')
AddEventHandler('syncBridgeSpawn', function()
  TriggerClientEvent('bridge:spawnBridge', -1)
end)

AddEventHandler('onResourceStart', function(res)
  if res==GetCurrentResourceName() then 
    TriggerEvent('syncBridgeSpawn')
    -- Sync initial state to all clients
    Citizen.Wait(1000) -- Wait for state to initialize
    for i = 1, 2 do
      local z = getCurrentBridgeZ(i)
      TriggerClientEvent('bridge:setHeight', -1, i, z, bridgeSpeed[i])
    end
  end
end)

-- Player loaded handlers (support multiple frameworks)
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
  syncPlayerState(source)
end)

RegisterNetEvent('esx:playerLoaded', function()
  syncPlayerState(source)
end)

-- Generic player ready event
AddEventHandler('playerConnecting', function()
  local source = source
  Citizen.Wait(2000) -- Wait for player to fully load
  syncPlayerState(source)
end)

function syncPlayerState(source)
  local SetAllLightStates = exports[GetCurrentResourceName()]:SetAllLightStates
  local lightStates = {}
  
  -- Get current light states (will be empty on first load, that's ok)
  for i = 1, 8 do
    local state = exports[GetCurrentResourceName()]:GetLightState(i)
    if state ~= nil then
      lightStates[i] = state
    end
  end
  
  TriggerClientEvent('bridge:syncLights', source, lightStates)
  TriggerClientEvent('bridge:spawnBridge', source)
  
  -- Sync bridge positions
  for i = 1, 2 do
    local z = getCurrentBridgeZ(i)
    TriggerClientEvent('bridge:setHeight', source, i, z, bridgeSpeed[i])
  end
end

-- Enhanced light sync with validation
RegisterNetEvent('bridge:syncLights', function(states)
  local source = source
  
  -- Permission check for light control
  if not hasPermission(source, 'UseCommands') then
    TriggerClientEvent('bridge:notification', source, 'You do not have permission to control lights', 'error')
    return
  end
  
  if type(states) ~= 'table' then return end
  
  local SetAllLightStates = exports[GetCurrentResourceName()]:SetAllLightStates
  SetAllLightStates(states)
  
  TriggerClientEvent('bridge:syncLights', -1, states)
end)

-- ================================================================
-- Enhanced server-driven sequence with state management
-- ================================================================

local function setLight(index, state)
  local SetLightState = exports[GetCurrentResourceName()]:SetLightState
  SetLightState(index, state)
  TriggerClientEvent('bridge:toggleTrafficLight', -1, index, state)
end

local function setAllLights(state)
  for i=1,8 do setLight(i,state) end
end

local function blinkRange(indices, seconds)
  local cycles = math.floor(seconds/2)
  for _=1,cycles do
    for _,i in ipairs(indices) do setLight(i,1) end
    Wait(1000)
    for _,i in ipairs(indices) do setLight(i,-1) end
    Wait(1000)
  end
end

local function setAllGates(isDown)
  for i=1,4 do TriggerClientEvent('bridge:gate:set', -1, i, isDown) end
end

RegisterNetEvent('bridge:RunSequence', function(index, raiseDelta, lowerDelta, openSpeed, closeSpeed)
  local source = source or 0  -- Allow server-side calls (source = 0)
  
  -- Permission check (skip for server-side calls)
  if source > 0 and not hasPermission(source, 'UseCommands') then
    TriggerClientEvent('bridge:notification', source, 'You do not have permission to run sequences', 'error')
    return
  end
  
  -- Check if sequence can start
  if not CanStartSequence() then
    TriggerClientEvent('bridge:notification', source, 'A sequence is already running', 'error')
    return
  end
  
  local sequenceId = 'seq_' .. os.time() .. '_' .. source
  if not RegisterSequence(sequenceId) then
    TriggerClientEvent('bridge:notification', source, 'Cannot start sequence - too many active', 'error')
    return
  end
  
  local idx         = tonumber(index)      or 1
  local RAISE_DELTA = tonumber(raiseDelta) or 20.0
  local LOWER_DELTA = tonumber(lowerDelta) or 20.0
  local OPEN_SPEED  = tonumber(openSpeed)  or 0.18
  local CLOSE_SPEED = tonumber(closeSpeed) or 0.28

  -- Notify all clients sequence started
  TriggerClientEvent('bridge:sequence:started', -1, idx)

  -- 1) stop traffic
  TriggerClientEvent('bridge:traffic:zones', -1, 'enable')
  setAllLights(1)

  -- 2) blink warn
  blinkRange({5,6,7,8},10)

  -- 3) gates down
  setAllGates(true)

  -- 4) short blink
  blinkRange({5,6,7,8},5)

  -- 5) raise bridge
  setHeight(idx, getCurrentBridgeZ(idx) + math.abs(RAISE_DELTA), true, OPEN_SPEED, nil)

  -- Wait for bridge to raise (estimate)
  local raiseTime = math.ceil((RAISE_DELTA / OPEN_SPEED) * 1000)
  Wait(raiseTime + 2000) -- Add buffer

  -- 6) blink while open
  blinkRange({5,6,7,8},30)

  -- 7) lower bridge
  setHeight(idx, getCurrentBridgeZ(idx) - math.abs(LOWER_DELTA), true, CLOSE_SPEED, nil)

  -- Wait for bridge to lower
  local lowerTime = math.ceil((LOWER_DELTA / CLOSE_SPEED) * 1000)
  Wait(lowerTime + 2000) -- Add buffer

  -- 8) blink while settling
  blinkRange({5,6,7,8},35)

  -- 9) gates up
  setAllGates(false)

  -- 10) final blink
  blinkRange({5,6,7,8},5)

  -- 11) green
  setAllLights(0)
  TriggerClientEvent('bridge:traffic:zones', -1, 'disable')
  
  -- Unregister sequence
  UnregisterSequence(sequenceId)
  TriggerClientEvent('bridge:sequence:ended', -1, idx)
end)

RegisterCommand('bridgeSeq', function(source, args)
  -- Permission check
  if not hasPermission(source, 'UseCommands') then
    TriggerClientEvent('bridge:notification', source, 'You do not have permission', 'error')
    return
  end
  
  TriggerEvent('bridge:RunSequence', source, tonumber(args[1]) or 1, tonumber(args[2]) or 20.0, tonumber(args[3]) or 20.0, tonumber(args[4]) or 0.18, tonumber(args[5]) or 0.28)
end, true)

-- Handle client sync requests
RegisterNetEvent('bridge:requestSync', function(index)
  local source = source
  local z = getCurrentBridgeZ(index)
  TriggerClientEvent('bridge:setHeight', source, index, z, bridgeSpeed[index])
end)

-- State broadcast thread for better sync
Citizen.CreateThread(function()
  while true do
    local interval = (Config and Config.Sync and Config.Sync.BroadcastInterval) or 1000
    Wait(interval)
    
    -- Broadcast bridge states periodically
    for i = 1, 2 do
      local state = GetBridgeState(i)
      if state and state.z then
        -- Only broadcast if not moving (to avoid spam)
        if not state.moving then
          TriggerClientEvent('bridge:setHeight', -1, i, state.z, bridgeSpeed[i])
        end
      end
    end
  end
end)
