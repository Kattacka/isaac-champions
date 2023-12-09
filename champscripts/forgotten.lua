local forgotten = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_THEFORGOTTEN
local CHARACTER2 = PlayerType.PLAYER_THESOUL

function forgotten:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY and cacheFlag~= CacheFlag.CACHE_DAMAGE and cacheFlag~= CacheFlag.CACHE_RANGE and cacheFlag~= CacheFlag.CACHE_TEARFLAG) then return end
    
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    --if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = player.MaxFireDelay *0.6 end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage * 0.2 - 3 end
    --if cacheFlag == CacheFlag.CACHE_RANGE then player.TearRange = 10000 end
    if cacheFlag == CacheFlag.CACHE_TEARFLAG then player.TearFlags = player.TearFlags | TearFlags.TEAR_PUNCH end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedForgotten == true then return end
        save.ItemObtainedForgotten = true
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
    
    if not (playerType == CHARACTER or playerType == CHARACTER2) then return end

    if playerType ~= currentChar then
        if playerType == CHARACTER then
            IsaacChampions:setBlindfold(player, false, true)
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_POINTY_RIB)
        else if playerType == CHARACTER2 then
            IsaacChampions:setBlindfold(player, true, true)
            player:AddCollectible(CollectibleType.COLLECTIBLE_POINTY_RIB)
        end
    end
    end

    currentChar = playerType
end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, forgotten.onPerfectUpdate)

local usedForgorRecall = false

function forgotten:InputAction(entity, _, buttonAction)
    if usedForgorRecall == false then return end
    local player = entity:ToPlayer()
    if player == nil then return end
    local playerType = player:GetPlayerType()
    
    if not (playerType == CHARACTER or playerType == CHARACTER2) then return end
    if buttonAction == ButtonAction.ACTION_DROP then
        print("fuck is this")
        usedForgorRecall = false
        return 1.0
    end
end
IsaacChampions:AddCallback(ModCallbacks.MC_INPUT_ACTION, forgotten.InputAction, InputHook.IS_ACTION_TRIGGERED)

function forgotten:onRecallUse(_, rng, player)
    if player == nil then return end
    local playerType = player:GetPlayerType()
    if not (playerType == CHARACTER or playerType == CHARACTER2) then return end

    usedForgorRecall = true
    player:UseActiveItem(CollectibleType.COLLECTIBLE_HOW_TO_JUMP)
end
IsaacChampions:AddCallback(ModCallbacks.MC_USE_ITEM, forgotten.onRecallUse, CollectibleType.COLLECTIBLE_RECALL)