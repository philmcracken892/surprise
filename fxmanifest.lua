fx_version "adamant"
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'phil'
description 'surprise'
version '1.0.0'

dependencies {
	"rsg-core"
	
}

client_script {
    'client/main.lua',
}

server_script {
	'server/main.lua',
}

shared_scripts {
    'config.lua',
}

lua54 'yes'


