-- ============================================================================
-- File        : fxmanifest.lua
-- Created     : 23/10/2025 20:13
-- Author      : ShadowCodding
-- YouTube     : https://www.youtube.com/@ShadowCodding
-- GitHub      : https://github.com/ShadowCodding/
-- Discord     : https://discord.com/s-dev
-- ============================================================================

fx_version 'cerulean'
game 'gta5'
author 'ShadowCodding'
description 'Boutique for FiveM'
version '1.0.0'
lua54 'yes'

shared_script {
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/*.lua'
}

escrow_ignore {
    "shared/*.lua",
    "client/*.lua",
    "server/*.lua",
}

dependency 'zUI'