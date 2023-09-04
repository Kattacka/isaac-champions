local apollyon_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function apollyon_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_APOLLYON_B then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true
    
    local challenge = Isaac.GetChallenge()
    Game().Challenge = Challenge.CHALLENGE_SOLAR_SYSTEM
    player:UpdateCanShoot()
    Game().Challenge = challenge

    local trinkets = {
        TrinketType.TRINKET_CRICKET_LEG,
        TrinketType.TRINKET_CRICKET_LEG,
        TrinketType.TRINKET_CRICKET_LEG,
    }

    for i = 1, #trinkets do

        player:AddTrinket(trinkets[i])
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)

    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND)
        player:AddCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND)
        player:AddCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND)
    end


    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, apollyon_b.onCache)