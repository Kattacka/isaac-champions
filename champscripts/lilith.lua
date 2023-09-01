local lilith = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function lilith:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_LILITH then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage *0.66 - 1.4 end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local trinkets = {
        TrinketType.TRINKET_FRIENDSHIP_NECKLACE,
        TrinketType.TRINKET_ADOPTION_PAPERS,
    }

    for i = 1, #trinkets do

        player:AddTrinket(trinkets[i])
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)

    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_KING_BABY)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, lilith.onCache)

