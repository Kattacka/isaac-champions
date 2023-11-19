local jacob_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_JACOB_B
local CHARACTER2 = PlayerType.PLAYER_JACOB2_B


function jacob_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_FIREDELAY then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER and player:GetPlayerType() ~= CHARACTER2 then return end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtainedJacob_b == true then return end
        save.ItemObtainedJacob_b = true
    end

    IsaacChampions:setBlindfold(player, true, true)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BATTERY)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT)
    end

    player:UseActiveItem(CollectibleType.COLLECTIBLE_ANIMA_SOLA, true)

end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, jacob_b.onCache)


function jacob_b:onNewFloor()
    local champions = IsaacChampions:getAllChampChars(CHARACTER)
    if (next(champions) == nil) then return end
    for i = 1, #champions do
        local player = champions[i]
        player:UseActiveItem(CollectibleType.COLLECTIBLE_ANIMA_SOLA, true)
    end
end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, jacob_b.onNewFloor)

local currentChar
function jacob_b:onPerfectUpdate(player)
    if player == nil then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    local playerType = player:GetPlayerType()
    
    if not (playerType == CHARACTER or playerType == CHARACTER2) then return end

    if playerType ~= currentChar then
        if playerType == CHARACTER then
            IsaacChampions:setBlindfold(player, true, true)
        else if playerType == CHARACTER2 then
            IsaacChampions:setBlindfold(player, true, true)
        end
    end
    end
    currentChar = playerType
end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, jacob_b.onPerfectUpdate)

if EID then
    local function crownPlayerCondition(descObj)
        if descObj and descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN then
            if (descObj.Entity ~= nil) then
                if (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER or (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER2 then return true end
            else
                if EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == CHARACTER or (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER2 then return true end
            end
        end
    end
    local function crownPlayerCallback(descObj)
        descObj.Description =
        "#{{Player".. CHARACTER .."}} {{ColorGray}}The Deserter" ..
        "#{{Trinket" .. TrinketType.TRINKET_BLIND_RAGE .. "}} {{ColorSilver}}Applies Blindfold" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BIRTHRIGHT .. "}} {{ColorSilver}}Birthright" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BATTERY .. "}} {{ColorSilver}}The Battery" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT .. "}} {{ColorSilver}}Lord of the Pit" 

        return descObj
    end

    EID:addDescriptionModifier("CrownJacobB", crownPlayerCondition, crownPlayerCallback)
end