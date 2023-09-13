local samson_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_SAMSON_B

function samson_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    player.Damage = player.Damage - 1.0

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    player:AddBrokenHearts(11)
 
    local trinkets = {
        TrinketType.TRINKET_CHILDS_HEART,
        TrinketType.TRINKET_PURPLE_HEART,
        TrinketType.TRINKET_DOOR_STOP,
        TrinketType.TRINKET_KEEPERS_BARGAIN,
    }
    mod:addTrinkets(player, trinkets)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CHAMPION_BELT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_CHAMPION_BELT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_ASTRAL_PROJECTION)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_WAFER)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_GOAT_HEAD) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_GOAT_HEAD)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_CONVERTER)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, samson_b.onCache)


-- function samson_b:onHit(entity, amount, flags)
--     local player = entity:ToPlayer() 
--     if not player:HasCollectible(CHAMPION_CROWN) then return end
--     if player:GetPlayerType() ~= CHARACTER then return end

--     local fakeDamageFlags = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE

--     if flags & fakeDamageFlags > 0 then return end

--     player:UseActiveItem(CollectibleType.COLLECTIBLE_BERSERK, true)
--     return true
-- end
-- mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, samson_b.onHit, EntityType.ENTITY_PLAYER)