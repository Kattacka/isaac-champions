local maggy = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function maggy:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_MAGDALENE then return end

    player.MaxFireDelay = player.MaxFireDelay * 2

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    player:AddMaxHearts(2)
    player:AddRottenHearts(2)

    local trinkets = {
        TrinketType.TRINKET_CROW_HEART,
        TrinketType.TRINKET_APPLE_OF_SODOM,
        TrinketType.TRINKET_FISH_TAIL,
    }

    for i = 1, #trinkets do
        if not player:HasTrinket(trinkets[i]) then
            player:AddTrinket(trinkets[i])
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
        end
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_YUM_HEART) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_YUM_HEART)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_YUCK_HEART) then
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_YUCK_HEART)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MULLIGAN) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_MULLIGAN)
    end

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, maggy.onCache)