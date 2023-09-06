local samson = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_SAMSON

function samson:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = player.MaxFireDelay * 3 end

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
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, samson.onCache)