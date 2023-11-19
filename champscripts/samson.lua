local samson = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_SAMSON

function samson:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then IsaacChampions.Utility:addNegativeTearMultiplier(player, 3) end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedSamson == true then return end
        save.ItemObtainedSamson = true
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BLOODY_LUST) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_BLOODY_LUST)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DULL_RAZOR) then
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SHARD_OF_GLASS) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_SHARD_OF_GLASS)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLOODY_GUST) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BLOODY_GUST)
    end
    
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, samson.onCache)

if EID then
    local function crownPlayerCondition(descObj)
        if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN then
            if (descObj.Entity ~= nil) then
                if (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER then return true end
            else
                if EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == CHARACTER then return true end
            end
        end
    end
    local function crownPlayerCallback(descObj)
        descObj.Description =
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Samson" ..
        "#\2  -66% Fire Rate down" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BLOODY_LUST .. "}} {{ColorSilver}}Bloody Lust" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_DULL_RAZOR .. "}} {{ColorSilver}}Pocket Dull Razor" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_SHARD_OF_GLASS .. "}} {{ColorSilver}}Shard of Glass" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BLOODY_GUST .. "}} {{ColorSilver}}Bloody Gust" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER .. "}} {{ColorSilver}}Curse of the Tower"

        return descObj
    end
    
    EID:addDescriptionModifier("CrownSamson", crownPlayerCondition, crownPlayerCallback)
end