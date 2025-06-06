fx_version 'cerulean'
game 'gta5'

author 'FiveM Scripts'
description 'ESX Civilian Jobs System'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

client_scripts {
    'client/client.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js'
}

dependencies {
    'es_extended',
    'oxmysql'
}