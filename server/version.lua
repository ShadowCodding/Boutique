-- ============================================================================
-- File        : version.lua
-- Created     : 03/11/2025 20:15
-- Author      : ShadowCodding
-- YouTube     : https://www.youtube.com/@ShadowCodding
-- GitHub      : https://github.com/ShadowCodding/
-- Discord     : https://discord.com/s-dev
-- ============================================================================

local function CompareVersions(v1, v2)
    local v1Parts = {v1:match("(%d+)%.(%d+)%.(%d+)")}
    local v2Parts = {v2:match("(%d+)%.(%d+)%.(%d+)")}

    for i = 1, 3 do
        local v1Part = tonumber(v1Parts[i]) or 0
        local v2Part = tonumber(v2Parts[i]) or 0
        if v1Part > v2Part then return 1 end
        if v1Part < v2Part then return -1 end
    end
    return 0
end

local ressource = GetInvokingResource() or GetCurrentResourceName()
local versionActuelle = GetResourceMetadata(ressource, 'version', 0)

if not versionActuelle then
    return print("^1[Boutique] - Impossible de récupérer la version^0")
end

PerformHttpRequest("https://raw.githubusercontent.com/ShadowCodding/Boutique/main/version.txt", function(code, currentVersion)
    if code == 200 then
        local serverlatest = currentVersion:gsub("%s+","")
        local comparison = CompareVersions(versionActuelle, serverlatest)

        if comparison < 0 then
            print("^1[Boutique] - Version obsolète ("..versionActuelle.."). Dernière version : "..serverlatest.."^7")
            print("^1[Boutique] - Discord : https://discord.gg/fCgXFJYVBv^7")
        elseif comparison == 0 then
            print("^2[Boutique] - Version à jour ("..versionActuelle..")^7")
            print("^2[Boutique] - Discord : https://discord.gg/fCgXFJYVBv^7")
        end
    else
        print("^1[Boutique] - Échec de la vérification de version. Code : "..code.."^7")
    end
end)