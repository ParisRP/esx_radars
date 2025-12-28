fx_version 'cerulean'
games { 'gta5' }

author 'ESX-PUBLIC, adapté pour ESX Legacy'
description 'Stationary Radars'
version '1.1.0'

shared_script '@es_extended/imports.lua'
shared_script 'config.lua'

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql'
}