local jacob = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_JACOB
local CHARACTER2 = PlayerType.PLAYER_ESAU
local json = require("json")

function jacob:onCache(player, cacheFlag)

        
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_SIZE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if not (player:GetPlayerType() == CHARACTER or player:GetPlayerType() == CHARACTER2) then return end
    
    local twinPlayer = player:GetOtherTwin()

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local twinSave = mod.SaveManager.GetRunSave(twinPlayer)
    if twinSave.ItemObtained == true then return end
    twinSave.ItemObtained = true


    player:UsePill(PillEffect.PILLEFFECT_SMALLER, PillColor.PILL_NULL, UseFlag.USE_NOHUD | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TRINITY_SHIELD) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_TRINITY_SHIELD)
    end

    local trinkets = {
        TrinketType.TRINKET_WOODEN_CROSS,
    }
    mod:addTrinkets(player, trinkets)

    if not twinPlayer:HasCollectible(CHAMPION_CROWN) then
        twinPlayer:AddCollectible(CHAMPION_CROWN)
    end

    twinPlayer:UsePill(PillEffect.PILLEFFECT_SMALLER, PillColor.PILL_NULL, UseFlag.USE_NOHUD | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM)
    if not twinPlayer:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE) then
        twinPlayer:AddCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE)
    end

    mod:addTrinkets(twinPlayer, trinkets)

    if not twinPlayer:HasCollectible(CHAMPION_CROWN) then
        twinPlayer:AddCollectible(CHAMPION_CROWN)
    end
    --Remove tainted damocles from tainted item pool
    if TaintedTreasure then
       if TaintedTreasure.taintedpoolloaded then
        for i, v in ipairs(TaintedTreasure.savedata.taintedsets) do
            if v[1] == CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE and v[2] == TaintedCollectibles.DIONYSIUS then
                table.remove(TaintedTreasure.savedata.taintedsets, i)
                break
            end
        end
        
		TaintedTreasure:SaveData(json.encode(TaintedTreasure.savedata))
	else
        for i, v in ipairs(TaintedTreasure.startingtaintedsets) do
            if v[1] == CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE and v[2] == TaintedCollectibles.DIONYSIUS then
                table.remove(TaintedTreasure.startingtaintedsets, i)
                break
            end
        end
	end
    end

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, jacob.onCache)

--Prevent DamoclesAPI from spawning three pedestals
if CCO then
    function jacob:customChallengeDamocles()
        local championChars = mod:getAllChampChars(CHARACTER)
        if (next(championChars) == nil) then
            return 0
        else
            print("delete")
            return -1
        end
    end
    CCO.DamoclesAPI.AddDamoclesCallback(jacob.customChallengeDamocles)
end

