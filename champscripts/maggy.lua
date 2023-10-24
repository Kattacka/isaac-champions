local maggy = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_MAGDALENE

function maggy:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then IsaacChampions.Utility:addNegativeTearMultiplier(player, 2) end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    player:AddMaxHearts(2)
    player:AddRottenHearts(2)

    local trinkets = {
        TrinketType.TRINKET_CROW_HEART,
        TrinketType.TRINKET_APPLE_OF_SODOM,
        TrinketType.TRINKET_FISH_TAIL,
    }
    IsaacChampions:addTrinkets(player, trinkets)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_YUM_HEART) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_YUM_HEART)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_YUCK_HEART) then
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_YUCK_HEART)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MULLIGAN) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_MULLIGAN)
    end

    player:AddBombs(1)

end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, maggy.onCache)

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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Magdeline" ..
        "#\2  -50% Fire Rate down" ..
        "#\1  1 Health up" ..
        "#{{RottenHeart}} Heals 1 Rotten Heart" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_YUM_HEART .. "}} {{ColorSilver}}Yum Heart" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_YUCK_HEART .. "}} {{ColorSilver}}Pocket Yuck Heart" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_MULLIGAN .. "}} {{ColorSilver}}The Mulligan" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_CROW_HEART .. "}} {{ColorSilver}}Crow Heart" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_APPLE_OF_SODOM .. "}} {{ColorSilver}}Apple of Sodom" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_FISH_TAIL .. "}} {{ColorSilver}}Fish Tail"

        return descObj
    end
    
    EID:addDescriptionModifier("CrownMaggy", crownPlayerCondition, crownPlayerCallback)
end