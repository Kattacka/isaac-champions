local apollyon_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_APOLLYON_B

function apollyon_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true
    
    mod:setBlindfold(player, true, true)

    local trinkets = {
        TrinketType.TRINKET_CRICKET_LEG,
        TrinketType.TRINKET_CRICKET_LEG,
        TrinketType.TRINKET_CRICKET_LEG,
    }
    mod:addTrinkets(player, trinkets)


    local collectibles = {
        CollectibleType.COLLECTIBLE_HIVE_MIND,
        CollectibleType.COLLECTIBLE_HIVE_MIND,
        CollectibleType.COLLECTIBLE_HIVE_MIND,
    }
    mod:addCollectibles(player, collectibles)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, apollyon_b.onCache)