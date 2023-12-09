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
        if save.ItemObtainedBluebaby_b == true then return end
        save.ItemObtainedBluebaby_b = true
    end

    IsaacChampions:setBlindfold(player, true, true)

    local trinkets = {
        TrinketType.TRINKET_BROWN_CAP,
    --    TrinketType.TRINKET_MOMS_PEARL + 32768,
    }

    IsaacChampions:addTrinkets(player, trinkets)

    IsaacChampions.Utility:dropActiveItem(player)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_FATE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_FATE)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_FATES_REWARD) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_FATES_REWARD)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_PYROMANIAC)
    end

    player:AddCollectible(CollectibleType.COLLECTIBLE_MOMS_BRACELET)
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bluebaby_b.onCache)

local usedBracelet = false

function bluebaby_b:InputAction(entity, inputHook, action)
    if entity and entity.Type == EntityType.ENTITY_PLAYER then
        local player = entity:ToPlayer()
        
        if not player:HasCollectible(CHAMPION_CROWN) then return end
        local playerType = player:GetPlayerType()
        if playerType ~= CHARACTER then return end
        if usedBracelet == false then return end
        if action == ButtonAction.ACTION_BOMB then
            usedBracelet = false
            if player:IsHoldingItem() then return end
            return true
        end
    end
end
IsaacChampions:AddCallback(ModCallbacks.MC_INPUT_ACTION, bluebaby_b.InputAction, InputHook.IS_ACTION_TRIGGERED)

function bluebaby_b:onBraceletUse(_, rng, player)
    if player == nil then return end
    local playerType = player:GetPlayerType()
    if playerType ~= CHARACTER then return end
        IsaacChampions.Schedule(9, function ()
        if player:IsHoldingItem() == false then
            usedBracelet = true
        end
    end,{})
end
IsaacChampions:AddCallback(ModCallbacks.MC_USE_ITEM, bluebaby_b.onBraceletUse, CollectibleType.COLLECTIBLE_MOMS_BRACELET)

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
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_MOMS_BRACELET .. "}} {{ColorSilver}}Mom's Bracelet" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_SCHOOLBAG .. "}} {{ColorSilver}}Schoolbag" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BIRTHRIGHT .. "}} {{ColorSilver}}Birthright" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_FATE .. "}} {{ColorSilver}}Fate" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_FATES_REWARD .. "}} {{ColorSilver}}Fate's Reward" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_PYROMANIAC .. "}} {{ColorSilver}}Pyromaniac" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_BROWN_CAP .. "}} {{ColorSilver}}Brown Cap" ..
        "#{{PoopPickup}} Mom's Bracelet can throw out poop spells"
        return descObj
    end
    EID:addDescriptionModifier("CrownBlueBabyB", crownPlayerCondition, crownPlayerCallback)
end