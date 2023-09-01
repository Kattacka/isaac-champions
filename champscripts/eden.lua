local eden = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")


function eden:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY and cacheFlag~= CacheFlag.CACHE_DAMAGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= PlayerType.PLAYER_EDEN then return end


    if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = (player.MaxFireDelay * 1.4) end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = (player.Damage * 0.75) - 1.0 end


    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    for i = 0, Isaac.GetItemConfig():GetCollectibles().Size -1, 1 do
        if player:HasCollectible(i) and i ~= CHAMPION_CROWN then
            player:RemoveCollectible(i)
        end
    end

    
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MINI_MUSH) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_MINI_MUSH)
    end
    
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LIBRA) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_LIBRA)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_GENESIS) then
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_GENESIS)
    end
    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eden.onCache)


function eden:onUse(_, rng, player)
if not player then return end
if not player:HasCollectible(CHAMPION_CROWN) then return end
if player:GetPlayerType() ~= PlayerType.PLAYER_EDEN then return end

local save = mod.SaveManager.GetRunSave(player) 
save.ItemObtained = true

player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
player:RemoveCollectible(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
player:RemoveCollectible(CollectibleType.COLLECTIBLE_MINI_MUSH)
player:RemoveCollectible(CollectibleType.COLLECTIBLE_LIBRA)


end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, eden.onUse, CollectibleType.COLLECTIBLE_GENESIS)