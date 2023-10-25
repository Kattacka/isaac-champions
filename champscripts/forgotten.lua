local forgotten = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_THEFORGOTTEN
local CHARACTER2 = PlayerType.PLAYER_THESOUL

function forgotten:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY and cacheFlag~= CacheFlag.CACHE_DAMAGE and cacheFlag~= CacheFlag.CACHE_RANGE) then return end
    
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    --if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = player.MaxFireDelay *0.6 end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage * 0.2 - 3 end
    --if cacheFlag == CacheFlag.CACHE_RANGE then player.TearRange = 10000 end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    local trinkets = {
        TrinketType.TRINKET_BRAIN_WORM,
    }
    IsaacChampions:addTrinkets(player, trinkets)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS)
    end
    
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, forgotten.onCache)

local currentChar
function forgotten:onPerfectUpdate(player)
    if player == nil then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    local playerType = player:GetPlayerType()
    
    if playerType == not (CHARACTER or CHARACTER2) then return end

    if playerType ~= currentChar then
        if playerType == CHARACTER then
            IsaacChampions:setBlindfold(player, false, true)
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_MERCURIUS)
        else if playerType == CHARACTER2 then
            IsaacChampions:setBlindfold(player, true, true)
            player:AddCollectible(CollectibleType.COLLECTIBLE_MERCURIUS)
        end
    end
    end

    currentChar = playerType
end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, forgotten.onPerfectUpdate)