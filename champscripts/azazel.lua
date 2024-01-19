local azazel = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_AZAZEL


function azazel:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY and cacheFlag~= CacheFlag.CACHE_DAMAGE and cacheFlag~= CacheFlag.CACHE_RANGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then IsaacChampions.Utility:addNegativeTearMultiplier(player, 1.75) end
    if cacheFlag == CacheFlag.CACHE_RANGE then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) or
        player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) then
            --do nothing
            else
                player.TearRange = -100 end
        end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = (player.Damage * 0.5) + 0.03 end

    local blacklist = {
        CollectibleType.COLLECTIBLE_BIRTHRIGHT,
        CollectibleType.COLLECTIBLE_ANTI_GRAVITY,
        CollectibleType.COLLECTIBLE_TINY_PLANET,
    }
    IsaacChampions.Utility:removeFromPools(blacklist)
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, azazel.onCache)

IsaacChampions:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if player:HasCollectible(CHAMPION_CROWN) and player:GetPlayerType() == CHARACTER then
        IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_BIRTHRIGHT, 1, AZAZEL)
        IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ANTI_GRAVITY, 1, AZAZEL)
        IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_TINY_PLANET, 1, AZAZEL)
    else
        IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_BIRTHRIGHT, 0, AZAZEL)
        IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ANTI_GRAVITY, 0, AZAZEL)
        IsaacChampions.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_TINY_PLANET, 0, AZAZEL)
    end
end)

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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Azazel" ..
        "#\2  -50% Damage down" ..
        "#{{Blank}}  -40% Fire Rate down" ..
        "#{{Blank}}  -∞ Range" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_BIRTHRIGHT .. "}} {{ColorSilver}}Birthright" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_ANTI_GRAVITY .. "}} {{ColorSilver}}Anti-Grav" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_TINY_PLANET .. "}} {{ColorSilver}}Tiny Planet"
        return descObj
    end
    
    EID:addDescriptionModifier("CrownAzazel", crownPlayerCondition, crownPlayerCallback)
end