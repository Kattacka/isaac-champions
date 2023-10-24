local bethany = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_BETHANY

function bethany:onCache(player, cacheFlag)
    if player == nil then return end
    if (cacheFlag ~= CacheFlag.CACHE_DAMAGE and cacheFlag ~= CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage / 2 + 0.7 end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        mod.Utility:addNegativeTearMultiplier(player, 1.25)
    end
    local save = mod.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    player:AddMaxHearts(-2)

    local trinkets = {
        TrinketType.TRINKET_DEVILS_CROWN
    }

    mod:addTrinkets(player, trinkets)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_REDEMPTION) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_REDEMPTION)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_PRAYER_CARD)

    player:AddBombs(1)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bethany.onCache)

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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Bethany" ..
        "#\2  -50% Damage down" ..
        "#{{Blank}}  -20% Fire Rate down" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES .. "}} Book of Virtues" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_PRAYER_CARD .. "}} {{ColorSilver}}Pocket Prayer Card" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION .. "}} {{ColorSilver}}Act of Contrition" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_REDEMPTION .. "}} {{ColorSilver}}Redemption" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_DEVILS_CROWN .. "}} {{ColorSilver}}Devil's Crown" 
        return descObj
    end
    
    EID:addDescriptionModifier("CrownBethany", crownPlayerCondition, crownPlayerCallback)
end