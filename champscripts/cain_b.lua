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

    local runData = mod.SaveManager.GetRunSave()
    if runData then
        runData.noTreasureRooms = true
    end

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