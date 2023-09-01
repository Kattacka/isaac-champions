local eden_b = {}
local CHARACTER = PlayerType.PLAYER_EDEN_B
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function eden_b:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local trinkets = {
        TrinketType.TRINKET_M,
        TrinketType.TRINKET_EXPANSION_PACK,
    }

    for i = 1, #trinkets do
        player:AddTrinket(trinkets[i])
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_SMELTER)

    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eden_b.onCache)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_MOMS_PURSE, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.LIL_CHEST, 1)
  end)