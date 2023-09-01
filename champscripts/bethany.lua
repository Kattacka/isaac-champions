local bethany = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function bethany:onCache(player, cacheFlag)
    if player == nil then return end
    if (cacheFlag ~= CacheFlag.CACHE_DAMAGE and cacheFlag ~= CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_BETHANY then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage / 2 + 0.7 end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = player.MaxFireDelay * 1.20 end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    player:AddMaxHearts(-2)

    local trinkets = {
        TrinketType.TRINKET_DEVILS_CROWN
    }

    for i = 1, #trinkets do
            player:AddTrinket(trinkets[i])
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_REDEMPTION) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_REDEMPTION)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_PRAYER_CARD)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bethany.onCache)