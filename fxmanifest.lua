fx_version 'cerulean'
game 'gta5'

name 'Jaysigx-Bridge'
description 'Bridge go upy and downy'
author 'Jaysigx'

client_script {
    'client/client.lua',
    'client/gates.lua'
}
server_scripts {
    'server/*.lua', 
}

shared_script {
    'config.lua' -- Include the config file here as well if needed
}

data_file 'DLC_ITYP_REQUEST' 'stream/*.ytyp' 

map 'map.lua' 
