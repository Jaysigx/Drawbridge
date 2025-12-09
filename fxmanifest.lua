fx_version 'cerulean'
game 'gta5'

name 'Jaysigx-DrawBridge'
description 'Drawbridge script for FiveM'
author 'Jaysigx'

lua54 'yes'

files {
    'stream/*'
}
client_script {
    'client/cl_notifications.lua',
    'client/cl_bridgegates.lua',
    'client/cl_bridgesequence.lua',
    'client/cl_movebridge.lua',
    'client/cl_spawnbridge.lua',
    'client/cl_trafficlights.lua',
    'client/cl_exports.lua'
}

server_script {
    'server/sv_state.lua',
    'server/sv_main.lua',
    'server/sv_exports.lua'
}

shared_script {
    'config.lua' -- Include the config file here as well if needed
}

exports {
    -- Client exports
    'MoveBridgeUp',
    'MoveBridgeDown',
    'bridgelights',
    'MoveGate',
    'MoveGates',
    'RaiseLowerGateByIndex',
    -- Server exports (available server-side only)
    'MoveBridge',
    'SetBridgeHeight',
    'GetBridgeHeight',
    'IsBridgeMoving',
    'SetTrafficLight',
    'SetAllTrafficLights',
    'GetTrafficLightState',
    'SetGate',
    'SetAllGates',
    'RunBridgeSequence',
    'CanRunSequence',
    'IsSequenceRunning',
    'EnableTrafficZones',
    'DisableTrafficZones',
    'GetBridgeState',
    'SetBridgeState',
    'GetLightState',
    'SetLightState',
    'SetAllLightStates'
}

this_is_a_map 'yes'

