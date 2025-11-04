-- ============================================================================
-- File        : _main.lua
-- Created     : 23/10/2025 20:29
-- Author      : ShadowCodding
-- YouTube     : https://www.youtube.com/@ShadowCodding
-- GitHub      : https://github.com/ShadowCodding/
-- Discord     : https://discord.com/s-dev
-- ============================================================================


local config = getConfig()
local _ = config.translate

if (config.framework == 'esx') then
    ESX = ESX or exports['es_extended']:getSharedObject()
elseif (config.framework == 'qbcore') then
    QBCore = QBCore or exports['qb-core']:GetCoreObject()
end

input_showBox = function(TextEntry, ExampleText, MaxStringLenght, isValueInt)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    local blockInput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockInput = false
        if isValueInt then
            local isNumber = tonumber(result)
            if isNumber and isNumber >= 0 then
                return result
            else
                return nil
            end
        end

        return result
    else
        Wait(500)
        blockInput = false
        return nil
    end
end

local function getVehicleProperties(vehicle)
    if (config.framework == 'esx' and ESX and ESX.Game and ESX.Game.GetVehicleProperties) then
        return ESX.Game.GetVehicleProperties(vehicle)
    elseif (config.framework == 'qbcore' and QBCore and QBCore.Functions and QBCore.Functions.GetVehicleProperties) then
        return QBCore.Functions.GetVehicleProperties(vehicle)
    end

    local model = GetEntityModel(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    return {
        model = model,
        plate = plate
    }
end

RegisterNetEvent('boutique:spawnVehicle', function(modelName, plate)
    if (not (modelName)) then return end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local modelHash = type(modelName) == 'number' and modelName or joaat(modelName)

    if (not (IsModelInCdimage(modelHash))) then
        return
    end

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNumberPlateText(vehicle, plate or string.format("%08d", math.random(10000000)))
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, "OFF")
    SetEntityAsMissionEntity(vehicle, true, true)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)

    local props = getVehicleProperties(vehicle)
    if (props and type(props) == 'table') then
        props.plate = plate or props.plate
        TriggerServerEvent('boutique:updateVehicleProps', props.plate, props)
    end

    SetModelAsNoLongerNeeded(modelHash)
end)

config.logs.info("Client started.")