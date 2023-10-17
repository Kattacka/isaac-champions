local azazel = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_AZAZEL


function azazel:onCache(player, cacheFlag)
    if player == nil then return end

    if (cacheFlag ~= CacheFlag.CACHE_FIREDELAY and cacheFlag~= CacheFlag.CACHE_DAMAGE and cacheFlag~= CacheFlag.CACHE_RANGE) then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then player.MaxFireDelay = player.MaxFireDelay * 1.76 end
    if cacheFlag == CacheFlag.CACHE_RANGE then player.TearRange = -100 end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then player.Damage = (player.Damage * 0.5) + 0.03 end

    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, azazel.onCache)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)

    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_BIRTHRIGHT, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_ANTI_GRAVITY, 1)
    mod.HiddenItemManager:CheckStack(player, CollectibleType.COLLECTIBLE_TINY_PLANET, 1)

end)

if EID then
    local function crownPlayerCondition(descObj)
        if descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CHAMPION_CROWN and (Game():GetNearestPlayer(descObj.Entity.Position)):GetPlayerType() == CHARACTER then return true end
    end
    local function crownPlayerCallback(descObj)
        EID:appendToDescription(descObj, 
        "#{{Player".. CHARACTER .."}} {{ColorGray}}Azazel" ..
        "#\2  -50% Damage down" ..
        "#{{Blank}}  -40% Fire Rate down" ..
        "#{{Blank}}  -∞ Range" ..
        "#{{Plus}} {{Collectible" .. CollectibleType.COLLECTIBLE_BIRTHRIGHT .. "}} Birthright" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_ANTI_GRAVITY .. "}} Anti-Grav" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_TINY_PLANET .. "}} Tiny Planet"
    )
        return descObj
    end
    
    EID:addDescriptionModifier("CrownAzazel", crownPlayerCondition, crownPlayerCallback)
end