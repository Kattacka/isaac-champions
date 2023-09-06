local jacob_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_JACOB_B


function jacob_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    mod:setBlindfold(player, true, true)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BATTERY)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT)
    end
    
    player:UseActiveItem(CollectibleType.COLLECTIBLE_ANIMA_SOLA, true)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, jacob_b.onCache)


function jacob_b:onNewFloor()
    local champions = mod:getAllChampChars(CHARACTER)
    if champions == nil or champions == {} then return end
    for i = 1, #champions do
        local player = champions[i]
        player:UseActiveItem(CollectibleType.COLLECTIBLE_ANIMA_SOLA, true)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, jacob_b.onNewFloor)
