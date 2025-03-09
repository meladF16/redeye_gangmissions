fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'vames™️'
description 'redeye_gangmissions'
version '1.0.4'

shared_script 'config.lua'

client_scripts {
	'client/client.lua'
}

server_scripts {
	'server/*.lua'
}

escrow_ignore {
	'config.lua',
	'client/client.lua',
	'server/server.lua',
	'server/version_check.lua',
}
dependency '/assetpacks'