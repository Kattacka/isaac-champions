local isaac_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_ISAAC_B

function isaac_b:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedIsaac_b == true then return end
        save.ItemObtainedIsaac_b = true
    end

    local trinkets = {
        TrinketType.TRINKET_WICKED_CROWN,
        TrinketType.TRINKET_HOLY_CROWN,
        TrinketType.TRINKET_BLOODY_CROWN,
    }
    IsaacChampions:addTrinkets(player, trinkets)

    player:AddCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)

    
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, isaac_b.onCache)

function isaac_b:onPickupInit(pickup)
    if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then return end
    local player = Isaac.GetPlayer()
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end


    -- for i=0, 5, 1 do
    --     local delay = 50* math.log(i)
    -- IsaacChampions.Schedule(delay, function ()

        player:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)

    -- end,{})
    -- end


    end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, isaac_b.onPickupInit)