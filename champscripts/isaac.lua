local isaac = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_ISAAC

function isaac:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end --Arbitrary cache just so it doesnt run 50 times with every cache
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true
    

    local trinkets = {
        TrinketType.TRINKET_DICE_BAG,
        TrinketType.TRINKET_CRACKED_DICE,
    }
    mod:addTrinkets(player, trinkets)

    player:RemoveCollectible(CollectibleType.COLLECTIBLE_D6)
    
    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_MOVING_BOX)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, isaac.onCache)

if EID then
    local function crownPlayerCondition(descObj)
        if descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN and (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER then return true end
    end
    local function crownPlayerCallback(descObj)
        EID:appendToDescription(descObj, 
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Isaac" ..
        "#\2  {{Collectible" .. CollectibleType.COLLECTIBLE_D6 .. "}} D6" ..
        "#\1  {{Collectible" .. CollectibleType.COLLECTIBLE_MOVING_BOX .. "}} Pocket Moving Box" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} {{Trinket" .. TrinketType.TRINKET_DICE_BAG .. "}} Dice Bag" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_CRACKED_DICE .. "}} Cracked Dice"
    )
        return descObj
    end
    
    EID:addDescriptionModifier("CrownIsaac", crownPlayerCondition, crownPlayerCallback)
end