# 🏗️ Drawbridge Script for FiveM

A comprehensive, server-synchronized drawbridge control system for FiveM servers. Features two drawbridges (car and train), traffic lights, barrier gates, and full server-side state management.

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![FiveM](https://img.shields.io/badge/FiveM-Cerulean-blue.svg)

---

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Commands](#-commands)
- [Exports](#-exports)
- [Server-Side Exports](#-server-side-exports)
- [Client-Side Exports](#-client-side-exports)
- [Usage Examples](#-usage-examples)
- [Framework Support](#-framework-support)
- [Troubleshooting](#-troubleshooting)
- [Credits](#-credits)

---

## ✨ Features

### Core Functionality
- ✅ **Two Drawbridges**: Car bridge and train bridge with independent control
- ✅ **Smooth Animation**: Minimum-jerk S-curve easing for realistic movement
- ✅ **Traffic Lights**: 8 traffic lights with full state control
- ✅ **Barrier Gates**: 4 animated barrier gates that raise/lower
- ✅ **Automatic Sequences**: Full bridge opening/closing sequences with timing

### Advanced Features
- 🔄 **Server-Side Synchronization**: All state managed server-side, synced to all clients
- 💾 **State Persistence**: Optional state saving (bridge positions persist across restarts)
- 🔐 **Permission System**: Configurable ACE permissions for bridge control
- 🎯 **Sequence Management**: Prevents conflicts, tracks active sequences
- 📡 **Multi-Framework Support**: Works with ESX, QBCore, and standalone
- 🔔 **Notification System**: Unified notifications for all frameworks
- 🛡️ **Desync Protection**: Automatic detection and correction of position desync

---

## 🚀 Installation

1. **Download** the resource and place it in your `resources` folder
2. **Rename** the folder to `drawbridge` (or your preferred name)
3. **Add** to your `server.cfg`:
   ```cfg
   ensure drawbridge
   ```
4. **Configure** settings in `config.lua` (optional)
5. **Restart** your server

### Requirements
- FiveM Server (Cerulean or newer)
- Lua 5.4 support
- Map files included in `stream/` folder

---

## ⚙️ Configuration

Edit `config.lua` to customize the script:

```lua
Config = {}

-- Bridge positions (don't change unless you move the bridges)
Config.Bridge1Position = vector3(353.3317, -2315.838, 6.9134)
Config.Bridge2Position = vector3(219.5085, -2319.442, 5.0135)

-- Commands
Config.Commands = true  -- Enable/disable commands

-- Traffic control
Config.AutomaticTrafficZones = true  -- Auto-stop traffic at red lights
Config.ProximityTrafficLights = true -- Auto-reset lights when near bridge

-- Permissions (optional)
Config.Permissions = {
    UseCommands = false,  -- Set to ACE permission string or false
    AdminOnly = false,    -- Require "bridge.admin" permission
}

-- State persistence (optional)
Config.StatePersistence = {
    Enabled = false,      -- Save state to file
    SaveInterval = 30000, -- Save every 30 seconds (ms)
}

-- Sequence settings
Config.Sequence = {
    LockDuringSequence = true,  -- Prevent manual control during sequences
    MaxConcurrentSequences = 1, -- Max simultaneous sequences
}

-- Sync settings
Config.Sync = {
    BroadcastInterval = 1000,  -- State broadcast interval (ms)
    ValidateState = true,       -- Validate state changes
}
```

---

## 🎮 Commands

### Bridge Control
```
/bridgeUp [index] [amount] [speed]
  - Raise bridge by amount
  - Example: /bridgeUp 1 20 0.20

/bridgeDown [index] [amount] [speed]
  - Lower bridge by amount
  - Example: /bridgeDown 1 20 0.26
```

### Traffic Lights
```
/bridgelights [state]
  - Set all traffic lights to state
  - States: 0=Green, 1=Red, 2=Yellow, 3=Reset
  - Example: /bridgelights 1
```

### Gates
```
/gate [index] [direction]
  - Control individual gate
  - Example: /gate 1 down

/gateall [direction]
  - Control all gates
  - Example: /gateall up
```

### Sequences
```
/bridgeSeq [index] [raise] [lower] [upSpeed] [downSpeed]
  - Run full bridge sequence
  - Example: /bridgeSeq 1 20 20 0.18 0.28
```

### Debug
```
/bridgeScan
  - Scan for bridge entities (debug)

/bridgeCull
  - Reapply LOD suppression (debug)
```

---

## 📦 Exports

### Server-Side Exports

Use these exports **server-side** in other resources:

#### Bridge Control
```lua
-- Move bridge by delta amount
exports['drawbridge']:MoveBridge(index, delta, speed)
-- index: 1 or 2 (bridge number)
-- delta: positive = up, negative = down
-- speed: optional movement speed in m/s

-- Set bridge to absolute height
exports['drawbridge']:SetBridgeHeight(index, height, speed)

-- Get current bridge height
local height = exports['drawbridge']:GetBridgeHeight(index)

-- Check if bridge is moving
local isMoving = exports['drawbridge']:IsBridgeMoving(index)
```

#### Traffic Light Control
```lua
-- Set individual traffic light
exports['drawbridge']:SetTrafficLight(lightIndex, state)
-- lightIndex: 1-8
-- state: 0=Green, 1=Red, 2=Yellow, 3=Reset

-- Set all traffic lights
exports['drawbridge']:SetAllTrafficLights(state)

-- Get traffic light state
local state = exports['drawbridge']:GetTrafficLightState(lightIndex)
```

#### Gate Control
```lua
-- Set individual gate
exports['drawbridge']:SetGate(gateIndex, isDown)
-- gateIndex: 1-4
-- isDown: true = lower, false = raise

-- Set all gates
exports['drawbridge']:SetAllGates(isDown)
```

#### Sequence Control
```lua
-- Run full bridge sequence
exports['drawbridge']:RunBridgeSequence(bridgeIndex, raiseDelta, lowerDelta, openSpeed, closeSpeed)
-- All parameters optional except bridgeIndex

-- Check if sequence can run
local canRun = exports['drawbridge']:CanRunSequence()

-- Check if sequence is running
local isRunning = exports['drawbridge']:IsSequenceRunning()
```

#### Traffic Zones
```lua
-- Enable traffic speed zones (stops traffic)
exports['drawbridge']:EnableTrafficZones()

-- Disable traffic speed zones
exports['drawbridge']:DisableTrafficZones()
```

#### State Management
```lua
-- Get full bridge state
local state = exports['drawbridge']:GetBridgeState(index)
-- Returns: { z = height, moving = bool, targetZ = height }

-- Set bridge state (advanced)
exports['drawbridge']:SetBridgeState(index, z, moving, targetZ)

-- Get/set light states
local lightState = exports['drawbridge']:GetLightState(lightIndex)
exports['drawbridge']:SetLightState(lightIndex, state)
exports['drawbridge']:SetAllLightStates(states)
```

### Client-Side Exports

Use these exports **client-side** in other resources:

```lua
-- Move bridge up
exports['drawbridge']:MoveBridgeUp(index, amount, speed)

-- Move bridge down
exports['drawbridge']:MoveBridgeDown(index, amount, speed)

-- Set all traffic lights
exports['drawbridge']:bridgelights(state)

-- Control gates
exports['drawbridge']:MoveGate(gateIndex, isLowering)
exports['drawbridge']:MoveGates(isLowering)
exports['drawbridge']:RaiseLowerGateByIndex(gateIndex, isLowering)
```

---

## 💡 Usage Examples

### Example 1: Simple Bridge Control (Server-Side)
```lua
-- In your resource's server file
RegisterCommand('openbridge', function(source, args)
    -- Raise bridge 1 by 20 units
    exports['drawbridge']:MoveBridge(1, 20.0, 0.20)
    
    -- Wait 10 seconds
    Wait(10000)
    
    -- Lower bridge 1 by 20 units
    exports['drawbridge']:MoveBridge(1, -20.0, 0.26)
end, true)
```

### Example 2: Traffic Light Integration (Server-Side)
```lua
-- Turn all lights red before bridge opens
exports['drawbridge']:SetAllTrafficLights(1) -- Red
exports['drawbridge']:EnableTrafficZones()

-- Open bridge
exports['drawbridge']:MoveBridge(1, 20.0)

-- Wait for bridge to open
Wait(15000)

-- Close bridge
exports['drawbridge']:MoveBridge(1, -20.0)

-- Wait for bridge to close
Wait(15000)

-- Turn lights green
exports['drawbridge']:SetAllTrafficLights(0) -- Green
exports['drawbridge']:DisableTrafficZones()
```

### Example 3: Full Sequence (Server-Side)
```lua
-- Run complete bridge sequence
if exports['drawbridge']:CanRunSequence() then
    exports['drawbridge']:RunBridgeSequence(1, 20.0, 20.0, 0.18, 0.28)
else
    print("A sequence is already running!")
end
```

### Example 4: Client-Side Bridge Control
```lua
-- In your resource's client file
RegisterCommand('testbridge', function()
    -- Move bridge up
    exports['drawbridge']:MoveBridgeUp(1, 15.0, 0.20)
    
    -- Wait
    Wait(5000)
    
    -- Move bridge down
    exports['drawbridge']:MoveBridgeDown(1, 15.0, 0.26)
end, false)
```

### Example 5: Event-Based Integration
```lua
-- Listen for bridge sequence events
RegisterNetEvent('bridge:sequence:started', function(bridgeIndex)
    print("Bridge sequence started for bridge " .. bridgeIndex)
    -- Your custom logic here
end)

RegisterNetEvent('bridge:sequence:ended', function(bridgeIndex)
    print("Bridge sequence ended for bridge " .. bridgeIndex)
    -- Your custom logic here
end)
```

### Example 6: Permission-Based Control
```lua
-- In config.lua, set:
Config.Permissions = {
    UseCommands = "bridge.commands",  -- Requires ACE permission
    AdminOnly = false,
}

-- Then in your server.cfg:
add_ace group.admin bridge.commands allow
add_ace group.admin bridge.admin allow
```

---

## 🔧 Framework Support

The script automatically detects and works with:

- **ESX**: Uses `ESX.ShowNotification()` for notifications
- **QBCore**: Uses `QBCore.Functions.Notify()` for notifications
- **Standalone**: Falls back to native notifications

Player sync events supported:
- `QBCore:Server:OnPlayerLoaded`
- `esx:playerLoaded`
- Generic `playerConnecting` event

---

## 🐛 Troubleshooting

### Bridge Not Moving
- Check if bridge entities are spawned: `/bridgeScan`
- Verify bridge positions in `config.lua`
- Check server console for errors

### Desync Issues
- Enable state persistence in config
- Check `Config.Sync.BroadcastInterval` (lower = more frequent sync)
- Use `/bridgeCull` to reapply LOD suppression

### Permissions Not Working
- Verify ACE permissions in `server.cfg`
- Check `Config.Permissions` settings
- Ensure `Config.Permissions.UseCommands` is set correctly

### Traffic Lights Not Syncing
- Check if `Config.ProximityTrafficLights` is interfering
- Verify light entities exist at configured positions
- Check server console for sync errors

---

## 📝 Changelog

### Version 2.0 (Current)
- ✨ Complete server-side synchronization
- ✨ State persistence system
- ✨ Permission system
- ✨ Sequence management
- ✨ Multi-framework support
- ✨ Comprehensive exports
- ✨ Desync protection
- ✨ Enhanced error handling

### Version 1.1
- Basic syncing
- Initial exports
- Traffic lights
- Config options

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Credits

- **Original Script**: Jaysigx
- **Bridge Models**: [PNWParksFan & Smallo](https://www.gta5-mods.com/maps/draw-bridge-map-script)
- **Enhanced Version**: Community contributions

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Check existing issues for solutions
- Review the documentation above

---

**Made with ❤️ for the FiveM community**
