local isaac = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_ISAAC

function isaac:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end --Arbitrary cache just so it doesnt run 50 times with every cache
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end
    

    local trinkets = {
        TrinketType.TRINKET_DICE_BAG,
        TrinketType.TRINKET_CRACKED_DICE,
    }
    IsaacChampions:addTrinkets(player, trinkets)

    player:RemoveCollectible(CollectibleType.COLLECTIBLE_D6)
    
    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_MOVING_BOX)

end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, isaac.onCache)

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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Isaac" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_D6 .. "}} {{ColorSilver}}D6" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_MOVING_BOX .. "}} {{ColorSilver}}Pocket Moving Box" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_DICE_BAG .. "}} {{ColorSilver}}Dice Bag" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_CRACKED_DICE .. "}} {{ColorSilver}}Cracked Dice"
        return descObj
    end
    
    EID:addDescriptionModifier("CrownIsaac", crownPlayerCondition, crownPlayerCallback)
end