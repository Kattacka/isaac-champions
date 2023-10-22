local eve = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_EVE

function eve:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_LUCK then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    player.Luck = player.Luck - 3.0

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local trinkets = {
        TrinketType.TRINKET_CROW_HEART,
        TrinketType.TRINKET_PANIC_BUTTON,
        TrinketType.TRINKET_BIBLE_TRACT,
    }
    mod:addTrinkets(player, trinkets)

    if player:GetActiveItem(0) == CollectibleType.COLLECTIBLE_RAZOR_BLADE or player:GetActiveItem(1) == CollectibleType.COLLECTIBLE_RAZOR_BLADE then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_RAZOR_BLADE)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_RAZOR_BLADE)
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON)
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_BIRD) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_DEAD_BIRD)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRD_CAGE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRD_CAGE)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eve.onCache)


function eve:onHit(entity, amount, flags)
    local player = entity:ToPlayer() 
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local fakeDamageFlags = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE

    if flags & fakeDamageFlags > 0 then return end

    player:UseActiveItem(CollectibleType.COLLECTIBLE_RAZOR_BLADE, true)
    return false
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, eve.onHit, EntityType.ENTITY_PLAYER)

if EID then
    local function crownPlayerCondition(descObj)
        if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN then
            if (descObj.Entity ~= nil) then
                if (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == PlayerType.PLAYER_EVE then return true end
            else
                if EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == PlayerType.PLAYER_EVE then return true end
            end
        end
    end
    local function crownPlayerCallback(descObj)
        descObj.Description =
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Eve" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_RAZOR_BLADE .. "}} Moves Razor Blade to Pocket Slot" ..
        "#\2 -3 Luck down" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON .. "}} {{ColorSilver}}Whore of Babylon" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_DEAD_BIRD .. "}} {{ColorSilver}}Dead Bird" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN .. "}} {{ColorSilver}}Dark Prince's Crown" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BIRD_CAGE .. "}} {{ColorSilver}}Bird Cage" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_PANIC_BUTTON .. "}} {{ColorSilver}}Panic Button" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_CROW_HEART .. "}} {{ColorSilver}}Crow Heart" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_BIBLE_TRACT .. "}} {{ColorSilver}}Bible Tract" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_RAZOR_BLADE .. "}} {{ColorRed}}Uses Razor Blade on hit"

        return descObj
    end
    EID:addDescriptionModifier("CrownEve", crownPlayerCondition, crownPlayerCallback)
end