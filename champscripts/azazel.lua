local azazel = {}
local CHARACTER = PlayerType.PLAYER_AZAZEL
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function azazel:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY and cacheFlag~= CacheFlag.CACHE_DAMAGE and cacheFlag~= CacheFlag.CACHE_RANGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = player.MaxFireDelay * 2.0 end
    if cacheFlag == CacheFlag.CACHE_RANGE then player.TearRange = -100 end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage * 0.6 end

    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, azazel.onCache)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_BIRTHRIGHT, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ANTI_GRAVITY, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_TINY_PLANET, 1)

  end)