local bluebaby = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_BLUEBABY

function bluebaby:onCache(player, cacheFlag)
    if player == nil then return end
    if not (cacheFlag == CacheFlag.CACHE_DAMAGE or cacheFlag == CacheFlag.CACHE_RANGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    --if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage - 2.4 end
    if cacheFlag == CacheFlag.CACHE_RANGE then player.TearRange = player.TearRange + 400 end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedBluebaby == true then return end
        save.ItemObtainedBluebaby = true
    end

    local trinkets = {
        TrinketType.TRINKET_WIGGLE_WORM,
        TrinketType.TRINKET_BLUE_KEY
    }
    IsaacChampions:addTrinkets(player, trinkets)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_POOP) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_POOP)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_CONTINUUM)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_THE_WIZ)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION)
    end
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bluebaby.onCache)