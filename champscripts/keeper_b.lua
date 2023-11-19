local keeper_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_KEEPER_B

function keeper_b:onCache(player, cacheFlag)
    if player == nil then return end
    if not (cacheFlag == CacheFlag.CACHE_DAMAGE)then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage *0.6 - 1.5 end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedKeeper == true then return end
        save.ItemObtainedKeeper = true
    end

    local trinkets = {
       TrinketType.TRINKET_TORN_POCKET
    }
    IsaacChampions:addTrinkets(player, trinkets)


    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MIDAS_TOUCH) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_MIDAS_TOUCH)
    end

    -- if not player:HasCollectible(CollectibleType.COLLECTIBLE_QUARTER) then
    --     player:AddCollectible(CollectibleType.COLLECTIBLE_QUARTER)
    -- end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_GOLDEN_RAZOR)
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, keeper_b.onCache)

