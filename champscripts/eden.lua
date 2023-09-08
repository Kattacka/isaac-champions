local eden = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_EDEN


function eden:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY and cacheFlag~= CacheFlag.CACHE_DAMAGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end


    if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = (player.MaxFireDelay * 1.4) end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = (player.Damage * 0.75) - 1.0 end


    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()

    if level:GetCurrentRoomIndex() == GridRooms.ROOM_GENESIS_IDX then return end

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
    local championEdens = mod:getAllChampChars(CHARACTER)
    if (next(championEdens) == nil) then return end

    for i = 1, #championEdens do
        local player = championEdens[i]
        local save = mod.SaveManager.GetRunSave(player) 

        player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_MINI_MUSH)
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_LIBRA)
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_GENESIS)
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, eden.onUse, CollectibleType.COLLECTIBLE_GENESIS)


function eden:onNewRoom()
    local championEdens  = mod:getAllChampChars(CHARACTER)

    if championEdens == {} then return end
    local game = Game()
    local room = game:GetRoom()
    local level = game:GetLevel()

    if level:GetCurrentRoomIndex() == GridRooms.ROOM_GENESIS_IDX then
        for i = 1, #championEdens do
            local player = championEdens[i]
                for j = 0, Isaac.GetItemConfig():GetCollectibles().Size - 1, 1 do
                    if player:HasCollectible(j) and j ~= CHAMPION_CROWN then
                        player:RemoveCollectible(j)
                    end
                end
        end
    end
end


mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, eden.onNewRoom)