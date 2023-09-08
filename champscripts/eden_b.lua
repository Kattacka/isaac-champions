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

    player:AddTrinket(TrinketType.TRINKET_TICK)

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_SMELTER)

    player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eden_b.onCache)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_BELLY_BUTTON, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_LIL_CHEST, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_CHAOS, 1)
  end)

  --disable treasure rooms
function eden_b:preFloorTransition()
    local championChars = mod:getAllChampChars(CHARACTER)
    if (next(championChars) == nil) then return end
    
    local save = mod.SaveManager.GetRunSave(nil)
    if save then
        save.challenge = Isaac.GetChallenge()
    end

    Game().Challenge = Challenge.CHALLENGE_PURIST
  end

mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, eden_b.preFloorTransition)


function eden_b:postFloorTransition()
    local save = mod.SaveManager.GetRunSave(nil)
    if save and save.challenge then
        Game().Challenge = save.challenge
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, eden_b.postFloorTransition)