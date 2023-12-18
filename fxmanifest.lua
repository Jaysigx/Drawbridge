fx_version 'cerulean'
game 'gta5'

name 'Jaysigx-DrawBridge'
description 'Drawbridge script for FiveM'
author 'Jaysigx'


files {
    'stream/*'
}
client_script {
    'client/cl_spawnbridge.lua',
    'client/cl_movebridge.lua',
    'client/cl_bridgegates.lua'
}

server_script {
    'server/main.lua'
}

shared_script {
    'config.lua' -- Include the config file here as well if needed
}

this_is_a_map 'yes'

