local apollyon = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_APOLLYON

function apollyon:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end --Arbitrary cache just so it doesnt run 50 times with every cache
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true
    
    local trinkets = {
        TrinketType.TRINKET_NO,
    }
    mod:addTrinkets(player, trinkets)

    player:RemoveCollectible(CollectibleType.COLLECTIBLE_VOID)
    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_VOID)

    --Make all items in room shop items so you can void only the desired items, then turn them back
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
    for _, entity in ipairs(entities) do
        local item = entity:ToPickup()
        print(item.Price)
        if item.SubType ~= 0 and item.Price == 0 then
            item.AutoUpdatePrice = false
            item.Price = 69
        end
    end
    local item1 = Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_SPINDOWN_DICE, Vector(0, 0), Vector.Zero, nil)
    local item2 = Isaac.Spawn(5, 100, CollectibleType.COLLECTIBLE_CROOKED_PENNY, Vector(0, 0), Vector.Zero, nil)
    item1:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    item2:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    player:UseActiveItem(CollectibleType.COLLECTIBLE_VOID, 0, 0)
    
    entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
    for _, entity in ipairs(entities) do
        local item = entity:ToPickup()
        if item.Price == 69 then
            item.AutoUpdatePrice = true
            item.Price = 0
        end
    end
 



end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, apollyon.onCache)

if EID then
    local function crownPlayerCondition(descObj)
        if descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN and (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER then return true end
    end
    local function crownPlayerCallback(descObj)

        EID:appendToDescription(descObj, 
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Apollyon" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_VOID .. "}} Pockets Void" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_VOID .. "}} {{ColorPurple}}Voids Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_SPINDOWN_DICE .. "}} {{ColorTransform}}Spindown Dice" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_CROOKED_PENNY .. "}} {{ColorTransform}}Crooked Penny" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_NO .. "}} {{ColorSilver}}No!" 
    )
        return descObj
    end
    
    EID:addDescriptionModifier("CrownApollyon", crownPlayerCondition, crownPlayerCallback)
end