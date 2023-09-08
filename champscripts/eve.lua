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


    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRD_CAGE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRD_CAGE)
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON)
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_BIRD) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_DEAD_BIRD)
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

