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

math.randomseed(os.time())

local charset = {}
for i = 48, 57 do table.insert(charset, string.char(i)) end
for i = 65, 90 do table.insert(charset, string.char(i)) end

local function randomPlate(length)
    local plate = ""
    for i = 1, length do
        local index = math.random(1, #charset)
        plate = plate .. charset[index]
    end
    return plate
end

local function isPlateTaken(plate)
    if (not plate) then return false end
    local query = nil
    if (config.framework == 'esx') then
        query = "SELECT plate FROM owned_vehicles WHERE plate = @plate LIMIT 1"
    elseif (config.framework == 'qbcore') then
        query = "SELECT plate FROM player_vehicles WHERE plate = @plate LIMIT 1"
    end
    if (not query) then return false end
    local result = MySQL.Sync.fetchScalar(query, {['@plate'] = plate})
    return (result ~= nil)
end

local function generateUniquePlate()
    local plate
    local attempts = 0
    repeat
        plate = randomPlate(8)
        attempts = attempts + 1
    until (not isPlateTaken(plate)) or attempts > 20
    return plate
end

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

local function refundPlayerCredits(license, amount)
    if (not license or not amount) then return end
    local query = ("UPDATE users SET credits = credits + @amount WHERE %s = @license"):format(config.column)
    MySQL.Async.execute(query, {['@amount'] = amount, ['@license'] = license})
end

local function registerVehicleOwnership(_src, license, vehicleData, plate, cb)
    if (not vehicleData or not vehicleData.vehicleModel) then
        cb(false)
        return
    end

    if (config.framework == 'esx') then
        local owner = config.license .. license
        local vehicleProps = {
            model = joaat(vehicleData.vehicleModel),
            plate = plate,
            vehicleLabel = vehicleData.vehicleLabel
        }
        local params = {
            ['@owner'] = owner,
            ['@plate'] = plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@type'] = 'car',
            ['@stored'] = 0
        }
        local query = "INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (@owner, @plate, @vehicle, @type, @stored)"
        MySQL.Async.execute(query, params, function(affectedRows)
            if (affectedRows and affectedRows > 0) then
                cb(true)
            else
                local fallbackQuery = "INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)"
                MySQL.Async.execute(fallbackQuery, params, function(rows)
                    cb(rows and rows > 0)
                end)
            end
        end)
    elseif (config.framework == 'qbcore') then
        local player = QBCore.Functions.GetPlayer(_src)
        if (not player) then
            cb(false)
            return
        end
        local citizenid = player.PlayerData and player.PlayerData.citizenid
        local licenseIdentifier = player.PlayerData and (player.PlayerData.license or (config.license .. license))
        if (not citizenid) then
            cb(false)
            return
        end
        local vehicleHash = joaat(vehicleData.vehicleModel)
        local vehicleProps = json.encode({
            model = vehicleHash,
            plate = plate,
            vehicle = vehicleData.vehicleModel,
            vehicleLabel = vehicleData.vehicleLabel
        })
        local params = {
            ['@license'] = licenseIdentifier,
            ['@citizenid'] = citizenid,
            ['@vehicle'] = vehicleData.vehicleModel,
            ['@hash'] = vehicleHash,
            ['@plate'] = plate,
            ['@state'] = 0,
            ['@mods'] = vehicleProps
        }
        local query = "INSERT INTO player_vehicles (license, citizenid, vehicle, hash, plate, state, mods) VALUES (@license, @citizenid, @vehicle, @hash, @plate, @state, @mods)"
        MySQL.Async.execute(query, params, function(affectedRows)
            cb(affectedRows and affectedRows > 0)
        end)
    else
        cb(false)
    end
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
        local vehicle = config.reward[category][item]
        if (not vehicle) then return end

        if (config.framework == 'esx') then
            player = ESX.GetPlayerFromId(_src)
        elseif (config.framework == 'qbcore') then
            player = QBCore.Functions.GetPlayer(_src)
        end

        if (not player) then
            config.notify(_('error_occurred'), _src)
            return
        end

        deductPlayerCredits(license, itemCost, function(success)
            if (not (success)) then
                config.notify(_('error_occurred'), _src)
                return
            end

            local plate = generateUniquePlate()
            if (not plate or #plate == 0) then
                plate = randomPlate(8)
            end
            registerVehicleOwnership(_src, license, vehicle, plate, function(stored)
                if (not stored) then
                    logs.err("Failed to store vehicle in database", license, vehicle.vehicleModel)
                    refundPlayerCredits(license, itemCost)
                    config.notify(_('error_occurred'), _src)
                    TriggerClientEvent('boutique:receiveCredits', _src, plyCredits)
                    return
                end

                config.notify(_('purchase_successful'), _src)
                TriggerClientEvent('boutique:spawnVehicle', _src, vehicle.vehicleModel, plate)
                TriggerClientEvent('boutique:receiveCredits', _src, plyCredits - itemCost)
                logs.suc("Vehicle purchased", ("License: %s"):format(license), ("Model: %s"):format(vehicle.vehicleModel), ("Plate: %s"):format(plate))
            end)
        end)
    end

end)

RegisterNetEvent('boutique:updateVehicleProps', function(plate, props)
    local _src = source
    if (not plate or not props) then return end
    if (type(props) ~= 'table') then return end

    local license = getPlayerIdentifier(_src)
    if (not license) then return end

    local encoded = json.encode(props)
    if (config.framework == 'esx') then
        local owner = config.license .. license
        local query = "UPDATE owned_vehicles SET vehicle = @vehicle WHERE owner = @owner AND plate = @plate"
        MySQL.Async.execute(query, {['@vehicle'] = encoded, ['@owner'] = owner, ['@plate'] = plate}, function(affectedRows)
            if (not affectedRows or affectedRows <= 0) then
                logs.err("Failed to update vehicle properties", owner, plate)
            end
        end)
    elseif (config.framework == 'qbcore') then
        local player = QBCore.Functions.GetPlayer(_src)
        if (not player) then return end
        local citizenid = player.PlayerData and player.PlayerData.citizenid
        if (not citizenid) then return end
        local query = "UPDATE player_vehicles SET mods = @mods WHERE citizenid = @citizenid AND plate = @plate"
        MySQL.Async.execute(query, {['@mods'] = encoded, ['@citizenid'] = citizenid, ['@plate'] = plate}, function(affectedRows)
            if (not affectedRows or affectedRows <= 0) then
                logs.err("Failed to update vehicle properties", citizenid, plate)
            end
        end)
    end
end)