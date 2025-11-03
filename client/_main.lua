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

config.logs.info("Client started.")