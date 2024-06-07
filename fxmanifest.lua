fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'oosayeroo' 
description 'sayer-bbq V2'
version '2.0'

shared_scripts {
    'config.lua'
}

client_scripts {
	'client/main.lua',
	'client/locked.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
}
