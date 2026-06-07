fx_version 'cerulean'
game 'gta5'
lua54 'yes'

-- qb-banking-alc-knbx
-- Free GPL-3.0 QBCore banking UI and UX overhaul by AitLilCat / ALC.
-- Based on qbcore-framework/qb-banking and original QBCore contributors.

author 'AitLilCat / ALC'
description 'Free QBCore banking UI and UX overhaul based on qb-banking'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/script.js',
    'html/style.css'
}
