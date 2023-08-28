local azazel = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function azazel:onCache(player, cacheFlag)
    if player == nil then return end

    if cacheFlag == CacheFlag.CACHE_RANGE then
        if not player:HasCollectible(CHAMPION_CROWN) then return end
        if player:GetPlayerType() ~= PlayerType.PLAYER_AZAZEL then return end
        player.TearRange = -100
    end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        if not player:HasCollectible(CHAMPION_CROWN) then return end
        if player:GetPlayerType() ~= PlayerType.PLAYER_AZAZEL then return end
        player.Damage = player.Damage * 0.6
    end

    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_AZAZEL then return end

    player.MaxFireDelay = player.MaxFireDelay * 2.0


    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TINY_PLANET) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_TINY_PLANET)
    end
    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, azazel.onCache)