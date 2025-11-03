-- ============================================================================
-- File        : main.lua
-- Created     : 23/10/2025 21:08
-- Author      : ShadowCodding
-- YouTube     : https://www.youtube.com/@ShadowCodding
-- GitHub      : https://github.com/ShadowCodding/
-- Discord     : https://discord.com/s-dev
-- ============================================================================

local config = getConfig()



-- When the script is started, check if column 'credits' exists in 'users' table, if not create it
MySQL.ready(function()
    local query = "SHOW COLUMNS FROM users LIKE 'credits'"
    MySQL.Async.fetchScalar(query, {}, function(result)
        if (not (result)) then
            config.logs.info("[^2Boutique^7] : 'credits' column not found in 'users' table. Creating it now...")
            local alterQuery = "ALTER TABLE users ADD COLUMN credits INT DEFAULT 0"
            MySQL.Async.execute(alterQuery, {}, function(affectedRows)
            end)
        else
            config.logs.suc("[^2Boutique^7] : 'credits' column found in 'users' table.")
        end
    end)
end)

local licenseType = {
    license = 'license:',
    steam = 'steam:',
    discord = 'discord:',
    xbox = 'xbl:',
    live = 'live:'
}

function getPlayerIdentifier(source)
    local identifiers = GetPlayerIdentifiers(source)
    local i = 1
    while identifiers[i] do
        local id = identifiers[i]
        if id:sub(1, #config.license) == config.license then
            return id:sub(#config.license + 1)
        end
        i = i + 1
    end
    return nil
end

local function getPlayerCredits(_src, license)
    local query = ("SELECT credits FROM users WHERE %s = @license"):format(config.column)
    MySQL.Async.fetchScalar(query, {['@license'] = license}, function(credits)
        if (credits) then
            TriggerClientEvent('boutique:receiveCredits', _src, credits)
        else
            TriggerClientEvent('boutique:receiveCredits', _src, 0)
        end
    end)
end

RegisterNetEvent('boutique:openMenu', function(src)
    local _src = source or src
    local license = getPlayerIdentifier(_src)
    if (not (license)) then
        print("[^1Boutique^7] [^1ERROR^7] : Could not retrieve player identifier for source " .. tostring(_src))
        TriggerClientEvent('boutique:closeMenu', _src)
        return
    end
    print("[^2Boutique^7] : Player " .. tostring(_src) .. " with license " .. license .. " opened the boutique menu.")
    getPlayerCredits(_src, license)
end)

RegisterCommand("give_credits", function(source, args, raw)
    local target = tonumber(args[1])
    local amount = tonumber(args[2])
    local license = getPlayerIdentifier(target)
    if (not (license)) then
        print("[^1Boutique^7] [^1ERROR^7] : Could not retrieve player identifier for source " .. tostring(target))
        return
    end
    if (source == 0) then
        local fetch = ("SELECT * FROM users WHERE %s=@license"):format(config.column)
        local task = MySQL.Sync.fetchAll(fetch, {["@license"] = license})
        if (task) then
            local nbCredits = task[1].credits
            newCredits = amount + nbCredits
            local up = ("UPDATE users SET credits=@credits WHERE %s=@license"):format(config.column)
            local update = MySQL.Sync.execute(up, {["@license"] = license, ["@credits"] = newCredits})
            if (update) then
                config.logs.suc(("Vous avez ajouté %s à la license suivante : %s | Il possède désormais ^3%s crédits"):format(amount, license, newCredits))
                TriggerClientEvent('boutique:receiveCredits', target, newCredits)
            else
                config.logs.err(("Une erreur est survenue lors de l'ajout de crédits à la license suivante : %s"):format(license))
            end
        end
    end
end)