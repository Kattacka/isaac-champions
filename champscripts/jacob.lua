local jacob = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_JACOB
local CHARACTER2 = PlayerType.PLAYER_ESAU

function jacob:onCache(player, cacheFlag)

        
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_SIZE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if not (player:GetPlayerType() == CHARACTER or player:GetPlayerType() == CHARACTER2) then return end
    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true


    player:UsePill(PillEffect.PILLEFFECT_SMALLER, PillColor.PILL_NULL, UseFlag.USE_NOHUD | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE)
    end

    local twinSave = mod.SaveManager.GetRunSave(player:GetOtherTwin())
    if twinSave.ItemObtained == true then return end
    player:GetOtherTwin():AddCollectible(CHAMPION_CROWN)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, jacob.onCache)

