local eden = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_EDEN


function eden:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY and cacheFlag~= CacheFlag.CACHE_DAMAGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end


    if cacheFlag == CacheFlag.CACHE_FIREDELAY then mod.Utility:addNegativeTearMultiplier(player, 2) end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = (player.Damage * 0.5) - 0.7 end


    local save = mod.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    local game = Game()
	local room = game:GetRoom()
	local level = game:GetLevel()

    if level:GetCurrentRoomIndex() == GridRooms.ROOM_GENESIS_IDX then return end

    local tempEffects = player:GetEffects()
    if not tempEffects:HasNullEffect(NullItemID.ID_ESAU_JR) then
        for i = 0, Isaac.GetItemConfig():GetCollectibles().Size -1, 1 do
            if player:HasCollectible(i) and i ~= CHAMPION_CROWN then
                player:RemoveCollectible(i)
            end
        end
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SAUSAGE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_SAUSAGE)
    end
    player:AddCollectible(CollectibleType.COLLECTIBLE_SAUSAGE)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LIBRA) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_LIBRA)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_GENESIS) then
        player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_GENESIS)
    end

    local heldTrinket = player:GetTrinket(0)
    if not (heldTrinket == 0 or heldTrinket == nil) then
        player:TryRemoveTrinket(heldTrinket)
    end

    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eden.onCache)


function eden:onUse(_, rng, player)
    if not player then return end
    local championEdens = mod:getAllChampChars(CHARACTER)
    if (next(championEdens) == nil) then return end

    for i = 1, #championEdens do
        local player = championEdens[i]

        player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_SAUSAGE)
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_SAUSAGE)
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_LIBRA)
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_GENESIS)
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, eden.onUse, CollectibleType.COLLECTIBLE_GENESIS)


function eden:onNewRoom()
    local championEdens  = mod:getAllChampChars(CHARACTER)

    if (next(championEdens) == nil) then return end
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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Eden" ..
        "#{{AchievementLocked}} Stops Treasure Room Generation" ..
        "#\2  -50% Damage down - 0.7" ..
        "#{{Blank}}  -50% Fire Rate down" ..
        "#{{Minus}} Removes all Starting Collectibles" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_GENESIS .. "}} {{ColorSilver}}Pocket Genesis" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_TMTRAINER .. "}} {{ColorSilver}}TMTrainer" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_LIBRA .. "}} {{ColorSilver}}Libra" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_SAUSAGE .. "}} {{ColorSilver}}Sausage x2" ..
        "#{{Warning}} {{Collectible" .. CollectibleType.COLLECTIBLE_GENESIS .. "}} Genesis removes all starting items"

        return descObj
    end
    EID:addDescriptionModifier("CrownEden", crownPlayerCondition, crownPlayerCallback)
end