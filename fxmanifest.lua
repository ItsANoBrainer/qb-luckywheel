-- https://docs.fivem.net/docs/scripting-reference/resource-manifest/resource-manifest/ --
fx_version 'cerulean'
game 'gta5'

author 'ItsANoBrainer'
description 'Casino Lucky Wheel'
version '1.0.3'

client_script 'client/main.lua'
server_script 'server/main.lua'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/*.lua'
}

dependencies {
    '/gameBuild:h4'
}
