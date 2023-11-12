local lilith = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_LILITH

function lilith:onCache(player, cacheFlag)
    if player == nil then return end
    if not (cacheFlag == CacheFlag.CACHE_DAMAGE or cacheFlag == CacheFlag.CACHE_RANGE)then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage *0.66 - 1.42 end
    if cacheFlag == CacheFlag.CACHE_RANGE then player.TearRange = player.TearRange - 60 end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    local trinkets = {
        TrinketType.TRINKET_FRIENDSHIP_NECKLACE,
        TrinketType.TRINKET_ADOPTION_PAPERS,
    }
    IsaacChampions:addTrinkets(player, trinkets)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_KING_BABY)
    end
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, lilith.onCache)

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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Lilith" ..
        "#\2  -40% Damage down" ..
        "#{{Blank}}  -1 Range down" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS .. "}} {{ColorSilver}}Box of Friends" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION .. "}} {{ColorSilver}}Cambion Conception" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BIRTHRIGHT .. "}} {{ColorSilver}}Birthright" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_KING_BABY .. "}} {{ColorSilver}}King Baby" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_PROPTOSIS .. "}} {{ColorSilver}}Proptosis" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_FRIENDSHIP_NECKLACE .. "}} {{ColorSilver}}Friendship Necklace" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_ADOPTION_PAPERS .. "}} {{ColorSilver}}Adoption Papers"
        return descObj
    end
    
    EID:addDescriptionModifier("CrownLilith", crownPlayerCondition, crownPlayerCallback)
end