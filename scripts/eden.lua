local eden = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function eden:onCache(player, cacheFlag)
    if player == nil then return end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then 
        if not player:HasCollectible(CHAMPION_CROWN) then return end
        if player:GetPlayerType() ~= PlayerType.PLAYER_EDEN then return end
        player.MaxFireDelay = (player.MaxFireDelay * 1.5) + 10
    end

    -- if cacheFlag == CacheFlag.CACHE_RANGE then 
    --     if not player:HasCollectible(CHAMPION_CROWN) then return end
    --     if player:GetPlayerType() ~= PlayerType.PLAYER_EDEN then return end
    
    --     player.TearRange = player.TearRange * 2
    -- end

    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_EDEN then return end

    player.Damage = (player.Damage * 0.66) - 0.5


    -- if not player:HasCollectible(CollectibleType.COLLECTIBLE_LIBRA) then
    --     player:AddCollectible(CollectibleType.COLLECTIBLE_LIBRA)
    -- end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_GENESIS) then
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_GENESIS)
    end
    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eden.onCache)