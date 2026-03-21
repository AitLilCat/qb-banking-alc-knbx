fx_version 'cerulean'
game 'gta5'
lua54 'yes'

-- qb-banking-ALC-KNBX (Free to use)
-- KNBX-inspired modular banking redesign by AitLilCat (ALC)
-- Based on qb-banking by Joshua Eger

author 'AitLilCat (ALC)'
description 'qb-banking ALC KNBX Edition - Modular, lightweight banking UI redesign with Dutch-inspired fintech styling'
version '2.1.0-alc'
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
    'html/style.css',
}
