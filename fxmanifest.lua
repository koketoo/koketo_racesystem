fx_version 'cerulean'
games { 'gta5' }
author 'koketo'
client_scripts {
    'client/scaleform.lua',
    'client/nui.lua',
    'client/main.lua',
    '@ox_lib/init.lua',
    'client/menu.lua',
    'client/builder.lua'
}

server_scripts {
    'server/main.lua',
    'server/races.json'
}

lua54 'yes'

ui_page 'html/index.html'

files {
    'html/style.css',
    'html/script.js',
    'html/index.html'
}
