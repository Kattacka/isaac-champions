local samson_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_SAMSON_B

function samson_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    player.Damage = player.Damage - 0.94

    local config = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE)
    player:RemoveCostume(config)
    config = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_WAFER)
    player:RemoveCostume(config)

    local save = mod.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    player:AddBrokenHearts(11)
 
    local trinkets = {
        TrinketType.TRINKET_PURPLE_HEART,
        TrinketType.TRINKET_DOOR_STOP,
        TrinketType.TRINKET_KEEPERS_BARGAIN,
    }
    mod:addTrinkets(player, trinkets)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CHAMPION_BELT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_CHAMPION_BELT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_WAFER)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_GOAT_HEAD) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_GOAT_HEAD)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_CONVERTER)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, samson_b.onCache)

if EID then
    local function crownPlayerCondition(descObj)
        if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN then
            if (descObj.Entity ~= nil) then
                if (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER then return true end
            else
                if EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == CHARACTER then return true end
            end
        end
    end
    local function crownPlayerCallback(descObj)
        descObj.Description =
        "#{{Player".. CHARACTER .."}} {{ColorGray}}The Savage" ..
        "#{{BrokenHeart}} Grants 11 Broken Hearts" ..
        "#{{Plus}} Adds Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_CONVERTER .. "}} {{ColorSilver}}Pocket Converter" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_CHAMPION_BELT .. "}} {{ColorSilver}}Champion Belt" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION .. "}} {{ColorSilver}}Astral Projection" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BIRTHRIGHT .. "}} {{ColorSilver}}Birthright" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_GOAT_HEAD .. "}} {{ColorSilver}}Goat Head" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_WAFER .. "}} {{ColorSilver}}Wafer" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE .. "}} {{ColorSilver}}Glyph of Balance" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_PURPLE_HEART .. "}} {{ColorSilver}}Purple Heart" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_DOOR_STOP .. "}} {{ColorSilver}}Door Stop" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_KEEPERS_BARGAIN .. "}} {{ColorSilver}}Keeper's Bargain" 

        return descObj
    end
    
    EID:addDescriptionModifier("CrownSamsonB", crownPlayerCondition, crownPlayerCallback)
end

function samson_b:onHit(entity, amount, flags)
    local player = entity:ToPlayer() 
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local stage = Game():GetLevel():GetStage()
    local roomType = Game():GetRoom():GetType()
    if (flags & DamageFlag.DAMAGE_SPIKES) ~= 0 and roomType == RoomType.ROOM_BOSS and Game():GetRoom():IsClear()
    and (stage == LevelStage.STAGE2_2 or stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE2_1) then
        if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BERSERK) then
            local pickup = Isaac.Spawn(5, 10, 2, entity.Position, 10*RandomVector(), player)
            pickup:ToPickup().Timeout = 60
            return true
        end
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BERSERK)
        return false
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, samson_b.onHit, EntityType.ENTITY_PLAYER)