local eve_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_EVE_B

function eve_b:onCache(player, cacheFlag)
    if player == nil then return end
    if (cacheFlag ~= CacheFlag.CACHE_DAMAGE and cacheFlag ~= CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage / 2 end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        IsaacChampions.Utility:addNegativeTearMultiplier(player, 0.73)
    end
    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    --player:AddMaxHearts(-2)

    -- local trinkets = {
    --     TrinketType.TRINKET_LIL_CLOT
    -- }

    --IsaacChampions:addTrinkets(player, trinkets)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_SUMPTORIUM) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_SUMPTORIUM)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SHARP_PLUG) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_SHARP_PLUG)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_HYPERCOAGULATION) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_HYPERCOAGULATION)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_LARYNX)

end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eve_b.onCache)


-- function eve_b:onPerfectUpdate(player)
--     if player == nil then return end
--     if not player:HasCollectible(CHAMPION_CROWN) then return end
--     local playerType = player:GetPlayerType()
    
--     if playerType ~= CHARACTER then return end
--     local tempEffects = player:GetEffects()
--     if not tempEffects:HasNullEffect(NullItemID.ID_BLOODY_BABYLON) then
--         print("bingo")
--         tempEffects:AddNullEffect(NullItemID.ID_BLOODY_BABYLON)
--     end

-- end
-- IsaacChampions:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, eve_b.onPerfectUpdate)


function eve_b:onFamiliarInit(entity)
    local champions = IsaacChampions:getAllChampChars(CHARACTER)
    if (next(champions) == nil) then return end
    for i = 1, #champions do
        local player = champions[i]
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SUMPTORIUM, false)

        local entities = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION)
        for _, bloodSplat in ipairs(entities) do
            print(bloodSplat.Variant)
            bloodSplat:Remove()
        end

    end

end
IsaacChampions:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, eve_b.onFamiliarInit, 238)


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