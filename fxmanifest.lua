fx_version 'cerulean'
game 'gta5'

name 'Jaysigx-DrawBridge'
description 'Drawbridge script for FiveM'
author 'Jaysigx'


files {
    'stream/**/car_drawbridge.ydr',
}
client_script {
    'client/client.lua',
    'client/gates.lua'
}

server_script {
    'server/server.lua'
}

shared_script {
    'config.lua' -- Include the config file here as well if needed
}

this_is_a_map 'yes'

