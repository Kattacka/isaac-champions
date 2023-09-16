local maggy_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_MAGDALENE_B

function maggy_b:onCache(player, cacheFlag)
    if player == nil then return end
    if not (cacheFlag == CacheFlag.CACHE_LUCK or cacheFlag == CacheFlag.CACHE_DAMAGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_LUCK then player.Luck = player.Luck + 8.01 end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = (player.Damage * 0.5) end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    mod:setBlindfold(player, true, true)

    player:AddBrokenHearts(6)

    -- local trinkets = {

    -- }
    -- mod:addTrinkets(player, trinkets)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, maggy_b.onCache)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ISAACS_HEART, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_HARLEQUIN_BABY, 1)

  end)