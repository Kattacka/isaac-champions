local apollyon_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_APOLLYON_B

function apollyon_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedApollyon_b == true then return end
        save.ItemObtainedApollyon_b = true
    end
    
    IsaacChampions:setBlindfold(player, true, true)

    -- local trinkets = {
    --     TrinketType.TRINKET_CRICKET_LEG + 32768,
    -- }
    -- IsaacChampions:addTrinkets(player, trinkets)

    local heldTrinket = player:GetTrinket(0)
    if not (heldTrinket == 0 or heldTrinket == nil) then
        player:TryRemoveTrinket(heldTrinket)
    end
    player:AddTrinket(TrinketType.TRINKET_CRICKET_LEG)
  
    if not (heldTrinket == 0 or heldTrinket == nil) then
        Isaac.Spawn(5, 350, heldTrinket, Isaac.GetFreeNearPosition(player.Position, 20), Vector.Zero, player)
    end

    IsaacChampions.Utility:dropActiveItem(player)

    local collectibles = {
        CollectibleType.COLLECTIBLE_HIVE_MIND,
        CollectibleType.COLLECTIBLE_BEST_BUD,
        CollectibleType.COLLECTIBLE_BEST_BUD,
        CollectibleType.COLLECTIBLE_BROWN_NUGGET,
    }
    IsaacChampions:addCollectibles(player, collectibles)

    player:RemoveCollectible(CollectibleType.COLLECTIBLE_BEST_BUD, true, nil, false)
    player:RemoveCollectible(CollectibleType.COLLECTIBLE_BEST_BUD, true, nil, false)

end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, apollyon_b.onCache)

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
        "#{{LordoftheFlies}} {{ColorTransform}} Beelzebub (3/3)" ..
        "#{{Blank}} " ..
        "#{{Player".. CHARACTER .."}} {{ColorGray}}The Empty" ..
        "#{{Trinket" .. TrinketType.TRINKET_BLIND_RAGE .. "}} {{ColorSilver}}Applies Blindfold" ..
        "#{{Plus}} Adds Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BROWN_NUGGET .. "}} {{ColorSilver}}Brown Nugget" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_HIVE_MIND .. "}} {{ColorSilver}}Hive Mind" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_CRICKET_LEG .. "}} {{ColorSilver}}Cricket Leg"
        return descObj
    end
    
    EID:addDescriptionModifier("CrownApollyonB", crownPlayerCondition, crownPlayerCallback)
end