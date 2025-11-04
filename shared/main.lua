-- ============================================================================
-- File        : main.lua
-- Created     : 23/10/2025 20:13
-- Author      : ShadowCodding
-- YouTube     : https://www.youtube.com/@ShadowCodding
-- GitHub      : https://github.com/ShadowCodding/
-- Discord     : https://discord.com/s-dev
-- ============================================================================

-- test pull request
local config = {}

config.locale = 'fr'
local licenseType = {
    license = 'license:',
    steam = 'steam:',
    discord = 'discord:',
    xbox = 'xbl:',
    live = 'live:'
}
config.license = licenseType.license
config.column = 'identifier'  -- Column in 'users' table to identify players (license, steam, discord, etc.)

config.framework = 'esx' -- 'esx' or 'qbcore'

if (config.framework == 'esx') then
    ESX = exports['es_extended']:getSharedObject()
elseif (config.framework == 'qbcore') then
    QBCore = exports['qb-core']:GetCoreObject()
end

config.notify = function(msg, source)
    -- Vérifier si la fonction est utilisé coté client ou serveur
    local isServer = (GetGameName() == "fxserver")
    if (config.framework == 'esx') then
        if isServer then
            TriggerClientEvent('esx:showNotification', source, msg)
        else
            ESX.ShowNotification(msg)
        end
    elseif (config.framework == 'qbcore') then
        if isServer then
            TriggerClientEvent('QBCore:Notify', source, msg)
        else
            QBCore.Functions.Notify(msg)
        end
    end
end

config.text = {
    ['fr'] = {
        -- Menu
        ['title'] = 'Boutique',
        ['description'] = 'Vous possédez (~r~%s~s~) crédits !',
        ['subtitle'] = 'Achetez des articles exclusifs',
        ['theme'] = 'default',
        ['key'] = 'F11',
        ['key_mapping'] = 'Ouvrir la boutique',
        -- Bouton
        ['buy'] = 'Acheter',
        ['credits'] = 'crédits',
        ['category'] = 'Catégorie',
        ['link_shop'] = 'Visitez notre boutique en ligne',
        ['link'] = "https://discord.gg/s-dev",
        ['yes_or_no'] = 'Oui / Non',
        ['desc_button_enought'] = 'Il vous manque ~r~%s crédits~s~ pour cet achat.',
        ['desc_button_no_enought'] = 'Il vous restera ~r~%s~s~ après cet achat.',
        ['buy_confirm'] = 'Voulez-vous acheter ~b~%s~s~ pour ~r~%s crédits~s~ ? | (Tapez ~g~Oui~s~ ou ~r~Non~s~)',
        -- Catégorie
        ['category_weapons'] = 'Armes',
        ['category_vehicles'] = 'Véhicules',
        ['category_clothes'] = 'Vêtements',
        ['category_accessories'] = 'Accessoires',
        ['category_misc'] = 'Divers',
        -- Notifications
        ['not_enough_credits'] = "Vous n'avez pas assez de crédits pour cet achat.\nManque : ~r~%s credits~s~",
        ['purchase_successful'] = 'Achat réussi ! Merci pour votre soutien.',
        ['purchase_cancelled'] = 'Achat annulé.',
        ['error_occurred'] = "Une erreur est survenue lors de l'achat. Veuillez réessayer plus tard.",
        ['already_own_weapon'] = "Vous possédez déjà l'arme ~b~%s~s~."
    }
}

config.translate = function(key, ...)
    local lang = config.locale
    local text = config.text[lang] and config.text[lang][key] or key
    return string.format(text, ...)
end

local _ = config.translate

config.giveAmmo = 100  -- Amount of ammo to give with weapons
config.reward = {
    [_('category_weapons')] = {
        ["WEAPON_PISTOL"] = {weaponName = 'WEAPON_PISTOL', weaponLabel = "Pistolet", credit = 1000, button},
        ["WEAPON_ASSAULTRIFLE"] = {weaponName = 'WEAPON_ASSAULTRIFLE', weaponLabel = "AK-47", credit = 5000, button},
    },
    [_('category_vehicles')] = {
        ["adder"] = {vehicleModel = 'adder', vehicleLabel = "Adder", credit = 100000, button},
        ["zentorno"] = {vehicleModel = 'zentorno', vehicleLabel = "Zentorno", credit = 150000, button},
    },
}

config.logs = {
    enable = true,
    -- Create log with style and text colored for easier identification
    suc = function(msg, ...)
        if config.logs.enable then
            print(("[^2Boutique^7] [^2SUCCESS^7] : %s %s"):format(msg, table.concat({...}, " - ")))
        end
    end,
    err = function(msg, ...)
        if config.logs.enable then
            print(("[^2Boutique^7] [^1ERROR^7] : %s %s"):format(msg, table.concat({...}, " - ")))
        end
    end,
    info = function(msg, ...)
        if config.logs.enable then
            print(("[^2Boutique^7] [^3INFO^7] : %s %s"):format(msg, table.concat({...}, " - ")))
        end
    end
}

function getConfig()
    return config
end

config.logs.info("Configuration loaded.")
