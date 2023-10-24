local bethany_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_BETHANY_B

function bethany_b:onCache(player, cacheFlag)
    if player == nil then return end
    if not (cacheFlag == CacheFlag.CACHE_DAMAGE or cacheFlag == CacheFlag.CACHE_FIREDELAY or cacheFlag == CacheFlag.CACHE_SHOTSPEED or cacheFlag == CacheFlag.CACHE_RANGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage - 1.27 end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        mod.Utility:addNegativeTearMultiplier(player, 1.2)
    end
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then player.ShotSpeed = player.ShotSpeed - 0.4 end
    if cacheFlag == CacheFlag.CACHE_RANGE then player.TearRange = player.TearRange - 40 end

    local save = mod.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    local trinkets = {
        TrinketType.TRINKET_WIGGLE_WORM
    }
    mod:addTrinkets(player, trinkets)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_LEMEGETON) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_LEMEGETON)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_TELEPATHY_BOOK)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bethany_b.onCache)


mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_CURSED_EYE, 1)
end)



-- function bethany_b:TearInit(tear)
--     if tear.Parent ~= nil and tear.Parent.Type == EntityType.ENTITY_PLAYER then
--         local player = tear.Parent:ToPlayer()
--         if not player:HasCollectible(CHAMPION_CROWN) then return end
--         if player:GetPlayerType() ~= CHARACTER then return end

--         tear.Mass = (tear.Mass * (1 / player.ShotSpeed))
--     end
-- end

-- mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, bethany_b.TearInit)