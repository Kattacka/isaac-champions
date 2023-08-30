local bluebaby = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function bluebaby:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_BLUEBABY then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local trinkets = {
        TrinketType.TRINKET_BROWN_CAP,
        TrinketType.TRINKET_MYSTERIOUS_CANDY,
        TrinketType.TRINKET_GIGANTE_BEAN,
    }

    for i = 1, #trinkets do
        if not player:HasTrinket(trinkets[i]) then
            player:AddTrinket(trinkets[i])
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
        end
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_POOP) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_POOP)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_IBS) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_IBS)
    end
    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bluebaby.onCache)