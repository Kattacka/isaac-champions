local cain = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_CAIN

function cain:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = (player.Damage * 0.5) + 0.75 end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    player:TryRemoveTrinket(TrinketType.TRINKET_PAPER_CLIP)

    local trinkets = {
        TrinketType.TRINKET_GILDED_KEY,
        TrinketType.TRINKET_CRYSTAL_KEY,
    }
    mod:addTrinkets(player, trinkets)

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_RED_KEY)

    player:AddPill(Game():GetItemPool():ForceAddPillEffect(PillEffect.PILLEFFECT_LUCK_DOWN));

    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
    end

    player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cain.onCache)


mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_FALSE_PHD, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_LITTLE_BAGGY, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_CRACKED_ORB, 1)

end)

--disable treasure rooms
function cain:preFloorTransition()
    local championChars = mod:getAllChampChars(CHARACTER)
    if (next(championChars) == nil) then return end
    
    local save = mod.SaveManager.GetRunSave(nil)
    if save then
        save.challenge = Isaac.GetChallenge()
    end

    Game().Challenge = Challenge.CHALLENGE_PURIST
  end

mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, cain.preFloorTransition)


function cain:postFloorTransition()
    local save = mod.SaveManager.GetRunSave(nil)
    if save and save.challenge then
        Game().Challenge = save.challenge
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, cain.postFloorTransition)