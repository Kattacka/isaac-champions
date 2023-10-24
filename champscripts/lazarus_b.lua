local lazarus_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local NEW_FLIP1 = Isaac.GetItemIdByName("Flip ")
local NEW_FLIP2 = Isaac.GetItemIdByName("Flip  ")
local CHARACTER = PlayerType.PLAYER_LAZARUS_B
local CHARACTER2 = PlayerType.PLAYER_LAZARUS2_B


function lazarus_b:onCache(player, cacheFlag)
    if player == nil then return end

    if cacheFlag~= CacheFlag.CACHE_RANGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if not (player:GetPlayerType() == CHARACTER or player:GetPlayerType() == CHARACTER2) then return end


        local save = IsaacChampions.SaveManager.GetRunSave(player)
        if save then

        if (save.TLazAInit == true or save.TLazBInit == true) then return end

        if (player:GetPlayerType() == CHARACTER and save.TLazAInit ~= true) then
            save.TLazAInit = true

            player:AddCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA)
            player:AddCollectible(CollectibleType.COLLECTIBLE_VANISHING_TWIN)
            player:AddCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS)
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_FLIP,false,ActiveSlot.SLOT_POCKET)
            player:SetPocketActiveItem(NEW_FLIP1)

            local playerID = player.ControllerIndex
            player:UseActiveItem(CollectibleType.COLLECTIBLE_FLIP, true)

            IsaacChampions.Schedule(1, function ()
                --code to run in 1 frame
              
                local newPlayer = lazarus_b:compare(playerID)
                if newPlayer == nil then return end
    
                if newPlayer:HasCollectible(CHAMPION_CROWN) then return end
                newPlayer:AddCollectible(CHAMPION_CROWN)

              end,{})

        else if (player:GetPlayerType() == CHARACTER2 and save.TLazBInit ~= true) then
            save.TLazBInit = true

            player:AddCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)
            player:AddCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS)
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_FLIP,false,ActiveSlot.SLOT_POCKET)
            player:SetPocketActiveItem(NEW_FLIP1)

            local playerID = player.ControllerIndex
            player:UseActiveItem(CollectibleType.COLLECTIBLE_FLIP, true)

            IsaacChampions.Schedule(1, function ()
                --code to run in 1 frame
              
                local newPlayer = lazarus_b:compare(playerID)
                if newPlayer == nil then return end
    
                if newPlayer:HasCollectible(CHAMPION_CROWN) then return end
                newPlayer:AddCollectible(CHAMPION_CROWN)

              end,{})
        end
        end
    end




end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, lazarus_b.onCache)

function lazarus_b:compare(playerCompare)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player.ControllerIndex == playerCompare then
            return player
        end
    end
    return nil
end


function lazarus_b:onFlip1Use(_, rng, player)
    if not player then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if not (player:GetPlayerType() == CHARACTER or player:GetPlayerType() == CHARACTER2) then return end

    local playerID = player.ControllerIndex
    player:UseActiveItem(CollectibleType.COLLECTIBLE_FLIP, true)

    local newPlayer = lazarus_b:compare(playerID)

    newPlayer:SetPocketActiveItem(NEW_FLIP1)
    newPlayer:SetActiveCharge(0, ActiveSlot.SLOT_POCKET)
end

IsaacChampions:AddCallback(ModCallbacks.MC_USE_ITEM, lazarus_b.onFlip1Use, NEW_FLIP1)

-- function lazarus_b:onFlip2Use(_, rng, player)
--     if not player then return end
--     if not player:HasCollectible(CHAMPION_CROWN) then return end
--     if not (player:GetPlayerType() == CHARACTER or player:GetPlayerType() == CHARACTER2) then return end

--     player:SetPocketActiveItem(NEW_FLIP1)
--     player:SetActiveCharge(0, ActiveSlot.SLOT_POCKET)
--     player:UseActiveItem(CollectibleType.COLLECTIBLE_FLIP, true)
-- end

-- IsaacChampions:AddCallback(ModCallbacks.MC_USE_ITEM, lazarus_b.onFlip2Use, NEW_FLIP2)

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
        "#{{Player".. CHARACTER .."}} {{Player".. CHARACTER2 .."}} {{ColorGray}}The Benighted" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_FLIP .. "}} {{Battery}}{{3}} Flip reduced to 3 charges " ..
        "#{{Blank}} No longer flips item pedestals" ..
        "#{{Player".. CHARACTER .."}} {{Plus}}   Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_EVES_MASCARA .. "}} {{ColorSilver}}Eve's Mascera" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_VANISHING_TWIN .. "}} {{ColorSilver}}Vanishing Twin" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_MORE_OPTIONS .. "}} {{ColorSilver}}More Options" ..
        "#{{Player".. CHARACTER2 .."}} {{Plus}}   Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_SOY_MILK .. "}} {{ColorSilver}}Soy Milk" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_MORE_OPTIONS .. "}} {{ColorSilver}}More Options" 

        return descObj
    end

    EID:addDescriptionModifier("CrownLazarusB", crownPlayerCondition, crownPlayerCallback)
end
