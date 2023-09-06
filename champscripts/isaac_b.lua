local isaac_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_ISAAC_B

function isaac_b:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    for i = 0, Isaac.GetItemConfig():GetCollectibles().Size -1, 1 do
        if player:HasCollectible(i) and i ~= CHAMPION_CROWN then
            player:RemoveCollectible(i)
        end
    end

    local trinkets = {
        TrinketType.TRINKET_WICKED_CROWN,
        TrinketType.TRINKET_HOLY_CROWN,
        TrinketType.TRINKET_BLOODY_CROWN,
    }
    mod:addTrinkets(player, trinkets)

    player:AddCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)

    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, isaac_b.onCache)

function isaac_b:onPickupInit(pickup)
    if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then return end
    local player = Isaac.GetPlayer()
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end


    -- for i=0, 5, 1 do
    --     local delay = 50* math.log(i)
    -- mod.Schedule(delay, function ()
        print(GetPtrHash(pickup))
        player:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        print(GetPtrHash(pickup))
    -- end,{})
    -- end


    end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, isaac_b.onPickupInit)