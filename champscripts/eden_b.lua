local eden_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_EDEN_B

function eden_b:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local runData = mod.SaveManager.GetRunSave()
    if runData then
        runData.noTreasureRooms = true
    end

    local tempEffects = player:GetEffects()
    if not tempEffects:HasNullEffect(NullItemID.ID_ESAU_JR) then
        for i = 0, Isaac.GetItemConfig():GetCollectibles().Size -1, 1 do
            if player:HasCollectible(i) and i ~= CHAMPION_CROWN then
                player:RemoveCollectible(i)
            end
        end
    end

    local heldTrinket = player:GetTrinket(0)
    player:TryRemoveTrinket(heldTrinket)


    local trinkets = {
        TrinketType.TRINKET_PANIC_BUTTON,
    }
    mod:addTrinkets(player, trinkets)

    player:AddTrinket(TrinketType.TRINKET_M)
    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_UNDEFINED)


    if tempEffects:HasNullEffect(NullItemID.ID_ESAU_JR) then return end
    player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eden_b.onCache)


mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_BLANKET, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_CHAOS, 1)
end)


function eden_b:onHit(entity, amount, flags)
    local player = entity:ToPlayer() 
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local fakeDamageFlags = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE
    if flags & fakeDamageFlags > 0 then return end

    if player:GetActiveCharge(ActiveSlot.SLOT_POCKET) < 6 then return end

    player:UseActiveItem(CollectibleType.COLLECTIBLE_UNDEFINED, true, 0, ActiveSlot.SLOT_POCKET)
    player:SetActiveCharge(player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + player:GetBatteryCharge(ActiveSlot.SLOT_POCKET) - 6, ActiveSlot.SLOT_POCKET)
    return true
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, eden_b.onHit, EntityType.ENTITY_PLAYER)