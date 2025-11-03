-- ============================================================================
-- File        : purchase.lua
-- Created     : 24/10/2025 14:12
-- Author      : ShadowCodding
-- YouTube     : https://www.youtube.com/@ShadowCodding
-- GitHub      : https://github.com/ShadowCodding/
-- Discord     : https://discord.com/s-dev
-- ============================================================================

local config = getConfig()
local logs = config.logs
local _ = config.translate

local function getPlayerCredits(_src, license)
    local query = ("SELECT credits FROM users WHERE %s = @license"):format(config.column)
    local credits = MySQL.Sync.fetchScalar(query, {['@license'] = license})
    return credits
end

local function deductPlayerCredits(license, amount, success)
    -- Return true if successful, false otherwise and new credits amount
    local query = ("UPDATE users SET credits = credits - @amount WHERE %s = @license"):format(config.column)
    MySQL.Async.execute(query, {['@amount'] = amount, ['@license'] = license}, function(affectedRows)
        if (affectedRows > 0) then
            success(true)
        else
            success(false)
        end
    end)
end

RegisterNetEvent("boutique:purchase", function(category, item)
    local _src = source
    if (not (_src)) then return end
    if (not (category) or not (item)) then return end

    if (not (config.reward[category])) then return end
    if (not (config.reward[category][item])) then return end

    local license = getPlayerIdentifier(_src)
    if (not (license)) then return end

    local plyCredits = getPlayerCredits(_src, license)
    if (not (plyCredits)) then
        config.notify(_('error_occurred'), _src)
        return
    end
    local itemCost = config.reward[category][item].credit
    if (plyCredits < itemCost) then
        config.notify(_('not_enough_credits',itemCost - plyCredits), _src)
        return
    end
    local player = nil
    if (category == _('category_weapons')) then
        local weapon = config.reward[category][item]
        -- Give weapon to player
        if (config.framework == 'esx') then
            player = ESX.GetPlayerFromId(_src)
            if (player.hasWeapon(weapon.weaponName, false)) then
                config.notify(_('already_own_weapon', weapon.weaponLabel), _src)
                return
            end
        elseif (config.framework == 'qbcore') then
            player = QBCore.Functions.GetPlayer(_src)
            if (player.Functions.HasItem(weapon.weaponName)) then
                config.notify(_('already_own_weapon', weapon.weaponLabel), _src)
                return
            end
        end

        deductPlayerCredits(license, itemCost, function(success)
            if (not (success)) then
                config.notify(_('error_occurred'), _src)
                return
            end

            if (config.framework == 'esx') then
                player.addWeapon(weapon.weaponName, config.giveAmmo)
            elseif (config.framework == 'qbcore') then
                player.Functions.AddItem(weaponName, 1)
            end
            config.notify(_('purchase_successful'), _src)
            TriggerClientEvent('boutique:receiveCredits', _src, plyCredits - itemCost)
        end)
    elseif (category == _('category_vehicles')) then
        -- Vehicle purchase logic here
        deductPlayerCredits(license, itemCost, function(success)
            if (not (success)) then
                config.notify(_('error_occurred'), _src)
                return
            end


            -- Vehicle delivery logic to be implemented
            config.notify(_('purchase_successful'), _src)
            TriggerClientEvent('boutique:receiveCredits', _src, plyCredits - itemCost)
        end)
    end

end)