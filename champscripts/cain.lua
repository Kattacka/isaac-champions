local cain = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_CAIN

function cain:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = (player.Damage * 0.5) + 0.75 end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedCain == true then return end
        save.ItemObtainedCain = true
    end

    local runData = IsaacChampions.SaveManager.GetRunSave()
    if runData then
        runData.noTreasureRooms = true
    end

    local tempEffects = player:GetEffects()

    player:TryRemoveTrinket(TrinketType.TRINKET_PAPER_CLIP)

    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_PAPER_CLIP)
    for _, entity in ipairs(entities) do
        local paperClip = entity:ToPickup()
        paperClip:Remove()
    end

    local trinkets = {
        TrinketType.TRINKET_CRYSTAL_KEY,
    }
    IsaacChampions:addTrinkets(player, trinkets)

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_RED_KEY)

    player:AddPill(Game():GetItemPool():ForceAddPillEffect(PillEffect.PILLEFFECT_LUCK_DOWN));

    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
    end

    player:AddKeys(-1)

    if tempEffects:HasNullEffect(NullItemID.ID_ESAU_JR) then return end
    IsaacChampions:RemoveTreasureRooms()

    local blacklist = {
        CollectibleType.COLLECTIBLE_RED_KEY,
        CollectibleType.COLLECTIBLE_FALSE_PHD,
        CollectibleType.COLLECTIBLE_CRACKED_ORB,
    }
    IsaacChampions.Utility:removeFromPools(blacklist)
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cain.onCache)


IsaacChampions:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_FALSE_PHD, 1, CAIN)
    IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_CRACKED_ORB, 1, CAIN)

end)

if EID then
    local function crownPlayerCondition(descObj)
        if descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN then
            if (descObj.Entity ~= nil) then
                if (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER then return true end
            else
                if EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == CHARACTER then return true end
            end
        end
    end
    local function crownPlayerCallback(descObj)
        descObj.Description =
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Cain" ..
        "#{{AchievementLocked}} Stops Treasure Room Generation" ..
        "#\2 -50% Damage" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_LUCKY_FOOT .. "}} Lucky Foot" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_PAPER_CLIP .. "}} Paper Clip" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_RED_KEY .. "}} {{ColorSilver}}Pocket Red Key" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_FALSE_PHD .. "}} {{ColorSilver}}False PHD" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_CRACKED_ORB .. "}} {{ColorSilver}}Cracked Orb" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_CRYSTAL_KEY .. "}} {{ColorSilver}}Crystal Key" ..
        "#{{Pill}} Gives a luck down pill"
        return descObj
    end
    EID:addDescriptionModifier("CrownCain", crownPlayerCondition, crownPlayerCallback)
end