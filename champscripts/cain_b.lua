local cain_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_CAIN_B

function cain_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local tempEffects = player:GetEffects()

    local trinkets = {
        TrinketType.TRINKET_NUH_UH,
        TrinketType.TRINKET_NO,
        TrinketType.TRINKET_LUCKY_ROCK,
        TrinketType.TRINKET_MYOSOTIS,
    }
    mod:addTrinkets(player, trinkets)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_NOTCHED_AXE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_NOTCHED_AXE)
    end
    player:SetActiveCharge(100)

    if tempEffects:HasNullEffect(NullItemID.ID_ESAU_JR) then return end
    player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cain_b.onCache)

--disable treasure rooms
function cain_b:preFloorTransition()
    local championChars = mod:getAllChampChars(CHARACTER)
    if (next(championChars) == nil) then return end
    
    local save = mod.SaveManager.GetRunSave(nil)
    if save then
        save.challenge = Isaac.GetChallenge()
    end

    Game().Challenge = Challenge.CHALLENGE_PURIST
  end

mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, cain_b.preFloorTransition)


function cain_b:postFloorTransition()
    local save = mod.SaveManager.GetRunSave(nil)
    if save and save.challenge then
        Game().Challenge = save.challenge
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, cain_b.postFloorTransition)
