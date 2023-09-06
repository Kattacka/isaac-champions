local eden_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_EDEN_B

function eden_b:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    for i = 0, Isaac.GetItemConfig():GetCollectibles().Size -1, 1 do
        if player:HasCollectible(i) and i ~= CHAMPION_CROWN then
            player:RemoveCollectible(i)
        end
    end

    local trinkets = {
        TrinketType.TRINKET_M,
        TrinketType.TRINKET_EXPANSION_PACK,
    }
    mod:addTrinkets(player, trinkets)


    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_SMELTER)

    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eden_b.onCache)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_BELLY_BUTTON, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_LIL_CHEST, 1)
  end)