local bluebaby_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function bluebaby_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_BLUEBABY_B then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local challenge = Isaac.GetChallenge()
    Game().Challenge = Challenge.CHALLENGE_SOLAR_SYSTEM
    player:UpdateCanShoot()
    Game().Challenge = challenge

    local trinkets = {
        TrinketType.TRINKET_BROWN_CAP,
        TrinketType.TRINKET_PETRIIED_POOP,

    }

    for i = 1, #trinkets do
            player:AddTrinket(trinkets[i])
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_FATE)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLUE_BABYS_ONLY_FRIEND) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BLUE_BABYS_ONLY_FRIEND)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MITRE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_MITRE)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_MOMS_BRACELET)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bluebaby_b.onCache)


function bluebaby_b:onNewFloor()
    local finalPlayer = nil
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:GetPlayerType() == PlayerType.PLAYER_JACOB_B then
            finalPlayer = player
        end
      end

    if finalPlayer == nil then return end
    if finalPlayer:GetPlayerType() ~= PlayerType.PLAYER_JACOB_B then return end
    if not finalPlayer:HasCollectible(CHAMPION_CROWN) then return end

    finalPlayer:UseActiveItem(CollectibleType.COLLECTIBLE_ANIMA_SOLA, true)
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, bluebaby_b.onNewFloor)
