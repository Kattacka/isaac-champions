local jacob = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_JACOB
local CHARACTER2 = PlayerType.PLAYER_ESAU
local json = require("json")

function jacob:onCache(player, cacheFlag)

        
    if player == nil then return end
    if not (cacheFlag == CacheFlag.CACHE_SIZE or cacheFlag == CacheFlag.CACHE_DAMAGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if not (player:GetPlayerType() == CHARACTER or player:GetPlayerType() == CHARACTER2) then return end
    
    local twinPlayer = player:GetOtherTwin()
    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage * 0.75 end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedJacob_b == true then return end
        save.ItemObtainedJacob_b = true
    end

    local twinSave = IsaacChampions.SaveManager.GetRunSave(twinPlayer)
    if twinSave then
        if twinSave.ItemObtainedJacob_b == true then return end
        twinSave.ItemObtainedJacob_b = true
    end

    player:UsePill(PillEffect.PILLEFFECT_SMALLER, PillColor.PILL_NULL, UseFlag.USE_NOHUD | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM)
    player:AddBrokenHearts(3)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE)
    end

    if player:GetPlayerType() == CHARACTER then
        player:AddCollectible(CollectibleType.COLLECTIBLE_TRINITY_SHIELD)
    else if twinPlayer:GetPlayerType() == CHARACTER then
        twinPlayer:AddCollectible(CollectibleType.COLLECTIBLE_TRINITY_SHIELD)
    end
    end

    local trinkets = {
        TrinketType.TRINKET_WOODEN_CROSS,
    }
    IsaacChampions:addTrinkets(player, trinkets)

    if not twinPlayer:HasCollectible(CHAMPION_CROWN) then
        twinPlayer:AddCollectible(CHAMPION_CROWN)
    end

    twinPlayer:UsePill(PillEffect.PILLEFFECT_SMALLER, PillColor.PILL_NULL, UseFlag.USE_NOHUD | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM)
    twinPlayer:AddBrokenHearts(3)
    if not twinPlayer:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE) then
        twinPlayer:AddCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE)
    end

    IsaacChampions:addTrinkets(twinPlayer, trinkets)

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

    local blacklist = {
        CollectibleType.COLLECTIBLE_DAMOCLES,
        CollectibleType.COLLECTIBLE_TRINITY_SHIELD,
    }
    IsaacChampions.Utility:removeFromPools(blacklist)
    end

end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, jacob.onCache)

function jacob:onHit(entity, amount, flags)
    local player = entity:ToPlayer()
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if not (player:GetPlayerType() == CHARACTER or player:GetPlayerType() == CHARACTER2) then return end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save and save.gotHit == true then return end

    local fakeDamageFlags = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE
    if flags & fakeDamageFlags > 0 then return end

    save.gotHit = true
    SFXManager():Play(SoundEffect.SOUND_KNIFE_PULL, 2, 0, false, 1, 0)
    player:BloodExplode()
    player:AddCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_ANEMIC))
end
IsaacChampions:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, jacob.onHit, EntityType.ENTITY_PLAYER)

--Prevent DamoclesAPI from spawning three pedestals
if CCO and CCO.DamoclesAPI then
    function jacob:customChallengeDamocles()
        local championChars = IsaacChampions:getAllChampChars(CHARACTER)
        if (next(championChars) == nil) then
            return 0
        else
            return -1
        end
    end
    CCO.DamoclesAPI.AddDamoclesCallback(jacob.customChallengeDamocles)
end

if EID then
    local function crownPlayerCondition(descObj)
        if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN then
            if (descObj.Entity ~= nil) then
                if (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER or (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER2 then return true end
            else
                if EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == CHARACTER or EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == CHARACTER2 then return true end
            end
        end
    end
    local function crownPlayerCallback(descObj)
        descObj.Description =
        "#{{Player".. CHARACTER .."}} {{Player".. CHARACTER2 .."}} {{ColorGray}}Jacob and Esau" ..
        "#{{BrokenHeart}} Grants 3 Broken Hearts" ..
        "#\2 -25% Damage down" ..
        "#\1 Size down" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE .. "}} {{ColorSilver}}Damocles" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_TRINITY_SHIELD .. "}} {{ColorSilver}}Trinity Shield" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_WOODEN_CROSS .. "}} {{ColorSilver}}Wooden Cross"

        return descObj
    end

    EID:addDescriptionModifier("CrownJacob", crownPlayerCondition, crownPlayerCallback)
end