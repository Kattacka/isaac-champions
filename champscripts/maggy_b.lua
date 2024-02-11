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
        if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SOY_MILK) <= 1 and not player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then
            IsaacChampions.Utility:addNegativeTearMultiplier(player, 5.5)
        else
            player.Damage = (player.Damage) * 0.3
        end
        print("pingas")
        --player.MaxFireDelay = IsaacChampions.Utility:toMaxFireDelay(tearsPerSecond)
        --player:SetMaggySwingCooldown(100)
    end

    local config = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
    player:RemoveCostume(config)



    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedMaggy_b == true then return end
        save.ItemObtainedMaggy_b = true
    end

    IsaacChampions:setBlindfold(player, true, true)

    player:AddHearts(2)

    -- local trinkets = {
    --     TrinketType.TRINKET_CROW_HEART,
    -- }
    -- IsaacChampions:addTrinkets(player, trinkets)

    if player:HasCollectible(CollectibleType.COLLECTIBLE_YUM_HEART) then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_YUM_HEART)
    end

    player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_SUPLEX)

    local blacklist = {
        CollectibleType.COLLECTIBLE_SUPLEX,
        CollectibleType.COLLECTIBLE_SOY_MILK,
        CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS,
    }
    IsaacChampions.Utility:removeFromPools(blacklist)
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, maggy_b.onCache)

local didHugAttack = false
IsaacChampions:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    print(player:GetMaggySwingCooldown())
    if didHugAttack == true and player:GetMaggySwingCooldown() > 4 then
        didHugAttack = false
        player:SetMaggySwingCooldown(math.floor(2.5*(math.max(0, player.MaxFireDelay))))
    end
    if player:GetMaggySwingCooldown() < 4 then didHugAttack = true end

    IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_SOY_MILK, 1)
    IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS, 1)
    IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ISAACS_HEART, 1)

end)


function maggy_b:onPickupInit(pickup)

    if not (pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_HALF) then return end
    local championChars = IsaacChampions:getAllChampChars(CHARACTER)
    if (next(championChars) == nil) then return end
    if not pickup.SpawnerEntity then return end
    if IsaacChampions.Utility:anyPlayerHasNullEffect(NullItemID.ID_SOUL_MAGDALENE) then return end

    IsaacChampions.Schedule(1, function ()
        if pickup.Timeout == 58 then
            local rng = pickup:GetDropRNG()
            local roll = rng:RandomFloat()
            if roll < 1 then
               pickup:Remove()
            end
        end
    end,{})
  end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, maggy_b.onPickupInit)

function maggy_b:onEntityDie(entity)
    if not entity:IsEnemy() then return end
    local player = Game():GetNearestPlayer(entity.Position)
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end
    local sprite = player:GetSprite()
    if not sprite:IsPlaying("LeapDown") then return end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.heartsSpawned == nil then
            save.heartsSpawned = 1
        else
            save.heartsSpawned = save.heartsSpawned + 1
        end

        if save.heartsSpawned > 3 then
            if save.heartsSpawned < 5 then
                IsaacChampions.Schedule(80, function ()
                    local save1 = IsaacChampions.SaveManager.GetRunSave(player)
                    save1.heartsSpawned = 0
                end,{})
            end
            return
        end
    end
    local pickup = Isaac.Spawn(5, 10, 2, entity.Position, (6*player.MoveSpeed)*RandomVector(), player)
    pickup:ToPickup().Timeout = 60
end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, maggy_b.onEntityDie)

function maggy_b:enterRoom()
    local room = Game():GetRoom()
    local level = Game():GetLevel()

    if not room:IsFirstVisit() then return end
    if (level:GetCurrentRoomIndex() ~= 84) then return end

    local champions = IsaacChampions:getAllChampChars(CHARACTER)
    if (next(champions) == nil) then return end
    for i = 1, #champions do
        local player = champions[i]
        local save = IsaacChampions.SaveManager.GetRunSave(player)
        if save then save.heartsSpawned = 0 end
    end

end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, maggy_b.enterRoom)

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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}The Dauntless " ..
        "#{{HalfHeart}} Stops enemies from dropping hearts" ..
        "#\2  -80% Damage down" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_YUM_HEART .. "}} {{ColorSilver}}Yum Heart" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_SUPLEX .. "}} {{ColorSilver}}Pocket Suplex" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS .. "}} {{ColorSilver}}Knockout Drops" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_ISAACS_HEART .. "}} {{ColorSilver}}Isaac's Heart" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SUPLEX .. "}} Suplexed enemies drop disappearing red hearts"

        return descObj
    end
    
    EID:addDescriptionModifier("CrownMaggyB", crownPlayerCondition, crownPlayerCallback)
end