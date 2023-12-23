fx_version 'cerulean'
game 'gta5'

name 'Jaysigx-DrawBridge'
description 'Drawbridge script for FiveM'
author 'Jaysigx'


files {
    'stream/*'
}
client_script {
    'client/cl_*.lua'
}

server_script {
    'server/sv_*.lua'
}

shared_script {
    'config.lua' -- Include the config file here as well if needed
}

exports {
    'MoveBridgeUp',
    'MoveBridgeDown',
    'bridgelights'
}

this_is_a_map 'yes'

