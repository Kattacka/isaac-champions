local bluebaby_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_BLUEBABY_B

function bluebaby_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    IsaacChampions:setBlindfold(player, true, true)

    local trinkets = {
        TrinketType.TRINKET_BROWN_CAP,
        TrinketType.TRINKET_MOMS_PEARL + 32768,
    }

    IsaacChampions:addTrinkets(player, trinkets)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_FATE)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLUE_BABYS_ONLY_FRIEND) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BLUE_BABYS_ONLY_FRIEND)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_MOMS_BRACELET)
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bluebaby_b.onCache)

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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}The Soiled" ..
        "#{{Trinket" .. TrinketType.TRINKET_BLIND_RAGE .. "}} {{ColorSilver}}Applies Blindfold" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_HOLD .. "}} Hold" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_MOMS_BRACELET .. "}} {{ColorSilver}}Pocket Mom's Bracelet" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BIRTHRIGHT .. "}} {{ColorSilver}}Birthright" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_FATE .. "}} {{ColorSilver}}Fate" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BLUE_BABYS_ONLY_FRIEND .. "}} {{ColorSilver}}???'s Only Friend" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_BROWN_CAP .. "}} {{ColorSilver}}Brown Cap" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_MOMS_PEARL .. "}} {{ColorOrange}}Golden Mom's Pearl"
        return descObj
    end
    EID:addDescriptionModifier("CrownBlueBabyB", crownPlayerCondition, crownPlayerCallback)
end