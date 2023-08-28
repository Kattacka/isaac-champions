local forgotten = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function forgotten:onCache(player, cacheFlag)
    if player == nil then return end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then 
        if not player:HasCollectible(CHAMPION_CROWN) then return end
        if player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN then return end
        player.MaxFireDelay = player.MaxFireDelay - 10
    end

    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN then return end

    player.Damage = player.Damage * 0.33

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE)
    end
    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, forgotten.onCache)