local maggy_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_MAGDALENE_B

local enemies_killed = {}

function maggy_b:onCache(player, cacheFlag)
    if player == nil then return end
    if not (cacheFlag == CacheFlag.CACHE_DAMAGE or cacheFlag == CacheFlag.CACHE_TEARFLAG or cacheFlag == CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end


    --if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = (player.Damage) * 0.8 end
    if cacheFlag == CacheFlag.CACHE_TEARFLAG then player.TearFlags = player.TearFlags | TearFlags.TEAR_PUNCH end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        mod.Utility:addNegativeTearMultiplier(player, 5.5)
    end

    local config = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
    player:RemoveCostume(config)

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    mod:setBlindfold(player, true, true)

    player:AddHearts(2)

    local trinkets = {
        TrinketType.TRINKET_CROW_HEART,
    }
    mod:addTrinkets(player, trinkets)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_YUM_HEART) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_YUM_HEART)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_SUPLEX)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, maggy_b.onCache)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_SOY_MILK, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ISAACS_HEART, 1)

end)


function maggy_b:onPickupInit(pickup)

    if not (pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_HALF) then return end
    local championChars = mod:getAllChampChars(CHARACTER)
    if (next(championChars) == nil) then return end
    if not pickup.SpawnerEntity then return end
    if mod.Utility:anyPlayerHasNullEffect(NullItemID.ID_SOUL_MAGDALENE) then return end

    mod.Schedule(1, function ()
        if pickup.Timeout == 58 then
            local rng = pickup:GetDropRNG()
            local roll = rng:RandomFloat()
            if roll < 1 then
               pickup:Remove()
            end
        end
    end,{})
  end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, maggy_b.onPickupInit)

function maggy_b:onEntityDie(entity)
    if not entity:IsEnemy() then return end
    local player = Game():GetNearestPlayer(entity.Position)
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if not player:GetPlayerType() == CHARACTER then return end
    local sprite = player:GetSprite()
    if not sprite:IsPlaying("LeapDown") then return end
    local pickup = Isaac.Spawn(5, 10, 2, entity.Position, (6*player.MoveSpeed)*RandomVector(), player)
    pickup:ToPickup().Timeout = 60


end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, maggy_b.onEntityDie)

-- function maggy_b:onUse(_, rng, player)
--     if not player then return end
--     if not player:HasCollectible(CHAMPION_CROWN) then return end
--     if player:GetPlayerType() ~= CHARACTER then return end
--     player:AddBlackHearts(1)

-- end

-- mod:AddCallback(ModCallbacks.MC_USE_ITEM, maggy_b.onUse, CollectibleType.COLLECTIBLE_SATANIC_BIBLE)