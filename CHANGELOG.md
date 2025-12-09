# Drawbridge Script - Enhanced Version Changelog

## Major Enhancements

### 🚀 Server-Side Synchronization
- **Complete state management**: All bridge positions, light states, and gate states are now managed server-side
- **Automatic state sync**: Bridge positions are automatically synchronized to all clients
- **State persistence**: Optional state saving to file (enabled in config) - bridge positions persist across server restarts
- **Periodic state broadcast**: Server periodically broadcasts state to ensure all clients stay in sync
- **Client sync validation**: Clients can request state sync if desync is detected

### 🔐 Permission System
- **Configurable permissions**: Set ACE permissions for bridge control
- **Admin-only mode**: Option to restrict bridge control to admins only
- **Command validation**: All commands now check permissions before execution
- **Framework support**: Works with ESX, QBCore, and standalone setups

### 🎯 Sequence Management
- **Sequence locking**: Prevents manual bridge control during automatic sequences
- **Concurrent sequence control**: Configurable maximum concurrent sequences
- **Sequence state tracking**: Server tracks active sequences to prevent conflicts
- **Better sequence timing**: Improved wait times and synchronization during sequences

### 📡 Enhanced Networking
- **Multi-framework support**: Automatic player sync for ESX, QBCore, and generic frameworks
- **Better entity resolution**: Improved client-side entity finding with retry logic
- **Network optimization**: Reduced unnecessary network traffic
- **Sync validation**: Automatic detection and correction of position desync

### 🔔 Notification System
- **Unified notifications**: Works with ESX, QBCore, or native notifications
- **Sequence notifications**: Players are notified when sequences start/end
- **Error messages**: Clear error messages for permission denials and conflicts

### 🛠️ Configuration Options
New config options added:
- `Config.Permissions`: Permission system configuration
- `Config.StatePersistence`: State saving configuration
- `Config.Sequence`: Sequence management settings
- `Config.Sync`: Synchronization settings

## New Files

### `server/sv_state.lua`
- Centralized state management
- State persistence (optional)
- Sequence tracking
- Export functions for state access

### `client/cl_notifications.lua`
- Unified notification system
- Framework detection
- Event handlers for notifications

## Improved Files

### `server/sv_main.lua`
- Enhanced permission checking
- Better state management integration
- Improved sequence handling
- Multi-framework player sync
- State broadcast thread

### `client/cl_movebridge.lua`
- Position tracking for sync validation
- Automatic desync detection and correction
- Improved entity resolution with retry logic

### `config.lua`
- New configuration options for all enhanced features

## Backward Compatibility

All existing commands and exports continue to work as before. The enhancements are additive and don't break existing functionality.

## Migration Notes

1. **Permissions**: By default, permissions are disabled (everyone can use commands). Enable in config if needed.
2. **State Persistence**: Disabled by default. Enable in config if you want bridge positions to persist across restarts.
3. **Sequence Locking**: Enabled by default. Disable if you want manual control during sequences.

## Usage Examples

### Enable Permissions
```lua
Config.Permissions = {
    UseCommands = "bridge.commands",  -- Requires ace permission
    AdminOnly = false,
}
```

### Enable State Persistence
```lua
Config.StatePersistence = {
    Enabled = true,
    SaveInterval = 30000,  -- Save every 30 seconds
}
```

### Adjust Sync Settings
```lua
Config.Sync = {
    BroadcastInterval = 2000,  -- Broadcast every 2 seconds
    ValidateState = true,       -- Validate all state changes
}
```

## Performance Improvements

- Reduced network traffic through smart broadcasting
- Better entity caching on client
- Optimized state updates
- Efficient sequence management

## Bug Fixes

- Fixed bridge position desync issues
- Improved entity resolution reliability
- Better handling of players joining mid-sequence
- Fixed state synchronization on resource restart

