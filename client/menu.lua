-- ============================================================================
-- File        : menu.lua
-- Created     : 23/10/2025 20:25
-- Author      : ShadowCodding
-- YouTube     : https://www.youtube.com/@ShadowCodding
-- GitHub      : https://github.com/ShadowCodding/
-- Discord     : https://discord.com/s-dev
-- ============================================================================
local config = getConfig()
local _ = config.translate
local reward = config.reward
local zUI = exports["zUI"]:getObject()
local main_menu = zUI.CreateMenu(_("title"), _("subtitle"), _("description", "0"), "default", nil, _("key"), _("key_mapping"))
local isOpen = false
zUI.SetOpenHandler(main_menu, function()
    TriggerServerEvent('boutique:openMenu')
    isOpen = true
end)

zUI.SetCloseHandler(main_menu, function()
    isOpen = false
end)

RegisterNetEvent('boutique:closeMenu', function()
    zUI.CloseAll()
    isOpen = false
end)

local myCredits = 0
RegisterNetEvent("boutique:receiveCredits", function(credits)
    myCredits = credits
    zUI.SetDescription(main_menu, _("description", credits))
end)


zUI.SetItems(main_menu, function()
    for key, value in pairs(reward) do
        zUI.Separator(("%s : (~r~%s~s~)"):format(_("category"), key))
        zUI.Line()
        for _key, item in pairs(value) do
            if (key == _("category_weapons")) then
                item.button = zUI.Button(item.weaponLabel, _(item.credit > myCredits and "desc_button_enought" or "desc_button_no_enought", item.credit > myCredits and item.credit - myCredits or myCredits - item.credit), {
                    RightLabel = ("~r~%s %s"):format(item.credit, _("credits"))
                }, function(onSelected)
                    if (onSelected) then
                        zUI.ManageFocus(false)
                        local confirm = input_showBox(_("buy_confirm", item.weaponLabel, item.credit), "", 4, false)
                        if (not (confirm)) then return end
                        if (confirm:lower() == "oui" or confirm:lower() == "yes") then
                            TriggerServerEvent("boutique:purchase", key, item.weaponName)
                        else
                            config.notify(_("purchase_cancelled"))
                        end
                        zUI.ManageFocus(true)                     
                    end
                end)
            elseif (key == _("category_vehicles")) then
                item.button = zUI.Button(item.vehicleLabel, nil, {
                    RightLabel = ("~r~%s %s"):format(item.credit, _("credits"))
                }, function(onSelected)
                end)

            end
        end

    end
    zUI.Line()
    zUI.LinkButton(_("link_shop"), nil, _("link"), {  })
end)


Citizen.CreateThread(function()
    while true do
        local delay = 2000
        if (isOpen) then
            delay = 200
            for key, value in pairs(reward) do
                    for key2, item in pairs(value) do
                        if (key == _("category_weapons")) then
                            if item.button == zUI.GetHoveredItem() then
                                delay = 200
                                zUI.ShowInfoBox(
                                        key,
                                        item.weaponLabel,
                                        "default",
                                        {
                                            { type = "text",    title = "Prix",        value = ("~r~%s credits"):format(item.credit) },
                                            { type = "text",    title = "Catégorie",   value = key },
                                            { type = "image",   title = "",      value = ("https://docs.fivem.net/weapons/%s.png"):format(item.weaponName) }
                                        }
                                )
                            end
                        elseif (key == _("category_vehicles")) then
                            if item.button == zUI.GetHoveredItem() then
                                delay = 200
                                zUI.ShowInfoBox(
                                        key,
                                        item.vehicleLabel,
                                        "default",
                                        {
                                            { type = "text",    title = "Prix",        value = ("~r~%s credits"):format(item.credit) },
                                            { type = "text",    title = "Catégorie",   value = key },
                                            { type = "image",   title = "",      value = ("https://docs.fivem.net/vehicles/%s.webp"):format(item.vehicleModel) }
                                        }
                                )
                            end
                    end
                end
            end
        end
        Citizen.Wait(delay)
    end
end)


