local cain_b = {}
local CHARACTER = PlayerType.PLAYER_CAIN_B
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function cain_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end


    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local trinkets = {
        TrinketType.TRINKET_NUH_UH,
        TrinketType.TRINKET_NO,
        TrinketType.TRINKET_LUCKY_ROCK,
        TrinketType.TRINKET_MYOSOTIS,
    }

    for i = 1, #trinkets do
        player:AddTrinket(trinkets[i])
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_NOTCHED_AXE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_NOTCHED_AXE)
    end
    player:SetActiveCharge(100)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cain_b.onCache)


