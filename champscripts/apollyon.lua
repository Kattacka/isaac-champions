local apollyon = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_APOLLYON

function apollyon:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end --Arbitrary cache just so it doesnt run 50 times with every cache
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true
    
    Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_SPINDOWN_DICE, Vector(0, 0), Vector.Zero, nil)
    Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_CROOKED_PENNY, Vector(0, 0), Vector.Zero, nil)

    player:UseActiveItem(CollectibleType.COLLECTIBLE_VOID, 0, 0)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, apollyon.onCache)

