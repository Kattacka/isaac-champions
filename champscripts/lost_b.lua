local lost_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_THELOST_B

function lost_b:onCache(player, cacheFlag)
    if player == nil then return end
    if not (cacheFlag == CacheFlag.CACHE_DAMAGE or cacheFlag == CacheFlag.CACHE_FIREDELAY or cacheFlag == CacheFlag.CACHE_FLYING) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end


    local tempEffects = player:GetEffects()
    if not tempEffects:HasNullEffect(NullItemID.ID_SPIRIT_SHACKLES_SOUL) then
        if cacheFlag == CacheFlag.CACHE_FLYING then player.CanFly = false end
    end

    -- if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = player.Damage / 2 + 0.7 end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        IsaacChampions.Utility:addNegativeTearMultiplier(player, 1.2)
    end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedLost_b == true then return end
        save.ItemObtainedLost_b = true
    end

    local trinkets = {
        TrinketType.TRINKET_BLIND_RAGE,
    }

    IsaacChampions:addTrinkets(player, trinkets)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SHACKLES) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SHACKLES)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_HALLOWED_GROUND) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_HALLOWED_GROUND)
    end

    -- if not player:HasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) then
    --     player:AddCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)
    -- end

    player:AddCollectible(CollectibleType.COLLECTIBLE_BREATH_OF_LIFE)

    local heldTrinket = player:GetTrinket(0)
    if not (heldTrinket == 0 or heldTrinket == nil) then
        player:TryRemoveTrinket(heldTrinket)
    end
    player:AddTrinket(TrinketType.TRINKET_CALLUS)
  
    if not (heldTrinket == 0 or heldTrinket == nil) then
        Isaac.Spawn(5, 350, heldTrinket, Isaac.GetFreeNearPosition(player.Position, 20), Vector.Zero, player)
    end

    if player:GetCard(0) == Card.CARD_HOLY then
        player:SetCard(0, 0)
    end
    if player:GetCard(1) == Card.CARD_HOLY then
        player:SetCard(1, 0)
    end
    local entities = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HOLY)
    for _, entity in ipairs(entities) do
        local holyCard = entity:ToPickup()
        holyCard:Remove()
    end
    local tempEffects = player:GetEffects()
    if tempEffects:HasNullEffect(NullItemID.ID_HOLY_CARD) then
        tempEffects:RemoveNullEffect(NullItemID.ID_HOLY_CARD, 1)
        tempEffects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, 1)
    end


end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, lost_b.onCache)


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