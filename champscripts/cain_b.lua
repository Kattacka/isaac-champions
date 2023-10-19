local cain_b = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_CAIN_B

function cain_b:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = mod.SaveManager.GetRunSave(player)
    if save.ItemObtained == true then return end
    save.ItemObtained = true

    local runData = mod.SaveManager.GetRunSave()
    if runData then
        runData.noTreasureRooms = true
    end

    local tempEffects = player:GetEffects()

    local trinkets = {
        TrinketType.TRINKET_NUH_UH,
        TrinketType.TRINKET_NO,
        TrinketType.TRINKET_LUCKY_ROCK,
        TrinketType.TRINKET_MYOSOTIS,
    }
    mod:addTrinkets(player, trinkets)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)
    end

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_NOTCHED_AXE) then
        player:AddCollectible(CollectibleType.COLLECTIBLE_NOTCHED_AXE)
    end
    player:SetActiveCharge(100)

    if tempEffects:HasNullEffect(NullItemID.ID_ESAU_JR) then return end
    mod:RemoveTreasureRooms()
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cain_b.onCache)

if EID then
    local function crownPlayerCondition(descObj)
        if descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN then
            if (descObj.Entity ~= nil) then
                if (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER then return true end
            else
                if EID.holdTabPlayer and EID.holdTabPlayer:ToPlayer():GetPlayerType() == CHARACTER then return true end
            end
        end
    end
    local function crownPlayerCallback(descObj)
        descObj.Description =
        "#{{Player".. CHARACTER .."}} {{ColorGray}}The Hoarder" ..
        "#{{AchievementLocked}} Stops Treasure Room Generation" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_NOTCHED_AXE .. "}} {{ColorSilver}}Notched Axe" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_SCHOOLBAG .. "}} {{ColorSilver}}Schoolbag" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_SMELTER .. "}} Smelts Trinkets:" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_LUCKY_ROCK .. "}} {{ColorSilver}}Lucky Rock" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_NO .. "}} {{ColorSilver}}No!" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_NUH_UH .. "}} {{ColorSilver}}Nuh Uh!" ..
        "#{{Blank}} {{Trinket" .. TrinketType.TRINKET_MYOSOTIS .. "}} {{ColorSilver}}Myosotis"
        return descObj
    end
    EID:addDescriptionModifier("CrownCainB", crownPlayerCondition, crownPlayerCallback)
end