local isaac = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function isaac:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end --Arbitrary cache just so it doesnt run 50 times with every cache
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_ISAAC then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true
    

    local trinkets = {
        TrinketType.TRINKET_DICE_BAG,
        TrinketType.TRINKET_CRACKED_DICE,
    }

    for i = 1, #trinkets do
        if not player:HasTrinket(trinkets[i]) then
            player:AddTrinket(trinkets[i])
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
        end
    end

    player:RemoveCollectible(CollectibleType.COLLECTIBLE_D6)
    
    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_MOVING_BOX)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, isaac.onCache)

