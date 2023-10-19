local eden_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_EDEN_B
local TELEPORT3 = Isaac.GetItemIdByName("Teleport 3.0")

function eden_b:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local runData = mod.SaveManager.GetRunSave()
    if runData then
        runData.noTreasureRooms = true
    end

    local tempEffects = player:GetEffects()
    if not tempEffects:HasNullEffect(NullItemID.ID_ESAU_JR) then
        for i = 0, Isaac.GetItemConfig():GetCollectibles().Size -1, 1 do
            if player:HasCollectible(i) and i ~= CHAMPION_CROWN then
                player:RemoveCollectible(i)
            end
        end
    end

    local heldTrinket = player:GetTrinket(0)
    if not (heldTrinket == 0 or heldTrinket == nil) then
        player:TryRemoveTrinket(heldTrinket)
    end


    local trinkets = {
        TrinketType.TRINKET_PANIC_BUTTON,
    }
    mod:addTrinkets(player, trinkets)

    player:SetPocketActiveItem(TELEPORT3)

    if tempEffects:HasNullEffect(NullItemID.ID_ESAU_JR) then return end
    mod:RemoveTreasureRooms()
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eden_b.onCache)


mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_BROKEN_MODEM, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_CHAOS, 1)
end)


function eden_b:CheckActiveSlot(player)
    local overcharge = 0
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then overcharge = 1 end
    for i = 0, 4, 1 do
        if player:GetActiveItem(i) == TELEPORT3 and
        player:GetActiveCharge(i) + player:GetBatteryCharge(i) >= 1 + overcharge then
            return i
        end
    end
    return nil
end

--Teleport player with teleport 3.0 on hit
function eden_b:Teleport3onHit(entity, amount, flags)
    local player = entity:ToPlayer()
    if not player:HasCollectible(TELEPORT3) then return end

    local fakeDamageFlags = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE
    if flags & fakeDamageFlags > 0 then return end

    local slot = eden_b:CheckActiveSlot(player)
    if slot == nil then return end
    player:SetActiveCharge(player:GetActiveCharge(slot) + player:GetBatteryCharge(slot) - 1, slot)

    player:UseActiveItem(CollectibleType.COLLECTIBLE_HOW_TO_JUMP, 1)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_UNDEFINED, 1)
    return nil
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, eden_b.Teleport3onHit, EntityType.ENTITY_PLAYER)

--Prevent reroll on hit
function eden_b:onHit(entity, amount, flags, source, countDown)
    local player = entity:ToPlayer()
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end
    local fakeDamageFlags = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE
    if flags & fakeDamageFlags > 0 then return end

    player:TakeDamage(amount, flags | DamageFlag.DAMAGE_NO_PENALTIES, source, countDown)
    return false
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, eden_b.onHit, EntityType.ENTITY_PLAYER)


function eden_b:onTeleport3Use(_, rng, player)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_HOW_TO_JUMP, 1)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT_2, true)
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, eden_b.onTeleport3Use, TELEPORT3)

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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}The Capricious" ..
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
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_GILDED_KEY .. "}} {{ColorSilver}}Guilded Key" ..
        "#{{Pill}} Gives a luck down pill"
        return descObj
    end
    EID:addDescriptionModifier("CrownEdenB", crownPlayerCondition, crownPlayerCallback)
end