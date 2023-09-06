local forgotten = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_THEFORGOTTEN

function forgotten:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY and cacheFlag~= CacheFlag.CACHE_DAMAGE and cacheFlag~= CacheFlag.CACHE_RANGE) then return end
    
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = player.MaxFireDelay *0.6 end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage * 0.33 end
    if cacheFlag == CacheFlag.CACHE_RANGE then player.TearRange = 10000 end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE)
    end
    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, forgotten.onCache)