local champ_util = {}

local GOLD_MODIFIER = 32768
--Example Schedule function
-- IsaacChampions.Schedule(1, function ()

-- end,{})

function champ_util:HUDOffset(x, y, anchor)
    local notches = math.floor(Options.HUDOffset * 10 + 0.5)
    local xoffset = (notches*2)
    local yoffset = ((1/8)*(10*notches+(-1)^notches+7))
    if anchor == 'topleft' then
      xoffset = x+xoffset
      yoffset = y+yoffset
    elseif anchor == 'topright' then
      xoffset = x-xoffset
      yoffset = y+yoffset
    elseif anchor == 'bottomleft' then
      xoffset = x+xoffset
      yoffset = y-yoffset
    elseif anchor == 'bottomright' then
      xoffset = x-xoffset * 0.8
      yoffset = y-notches * 0.6
    else
      error('invalid anchor provided. Must be one of: \'topleft\', \'topright\', \'bottomleft\', \'bottomright\'', 2)
    end
    return math.floor(xoffset + 0.5), math.floor(yoffset + 0.5)
end


function champ_util:HUDOffsetVector(vector, anchor)
    local x, y = champ_util:HUDOffset(vector.X, vector.Y, anchor)
    return Vector(x, y)
end

function champ_util:toTearsPerSecond(maxFireDelay)
    return 30 / (maxFireDelay + 1)
end

function champ_util:toMaxFireDelay(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

function champ_util:addNegativeTearMultiplier(player, multiplier)
    local tearsPerSecond = IsaacChampions.Utility:toTearsPerSecond(player.MaxFireDelay)
    tearsPerSecond = tearsPerSecond / multiplier
    player.MaxFireDelay = IsaacChampions.Utility:toMaxFireDelay(tearsPerSecond)
end

function champ_util:dropActiveItem(player)
    local heldActive = player:GetActiveItem(0)
    if not (heldActive == 0 or heldActive == nil) then
        player:RemoveCollectible(heldActive)
        Isaac.Spawn(5, 100, heldActive, Isaac.GetFreeNearPosition(player.Position, 20), Vector.Zero, player)
    end
end

function champ_util:hasRevive(player)

    local reviveItems = {
        CollectibleType.COLLECTIBLE_1UP,
        CollectibleType.COLLECTIBLE_DEAD_CAT,
        CollectibleType.COLLECTIBLE_INNER_CHILD,
        CollectibleType.COLLECTIBLE_GUPPYS_COLLAR,
        CollectibleType.COLLECTIBLE_LAZARUS_RAGS,
        CollectibleType.COLLECTIBLE_ANKH,
        CollectibleType.COLLECTIBLE_JUDAS_SHADOW,
    }

    local reviveTrinkets = {
        TrinketType.TRINKET_BROKEN_ANKH,
        TrinketType.TRINKET_MISSING_POSTER,
    }

    local reviveConsumable = Card.CARD_SOUL_LAZARUS

    local hasRevive = false
    for i = 1, #reviveItems do
        local item = reviveItems[i]
        if player:HasCollectible(item, true) then
            hasRevive = true
        end
    end
    for i = 1, #reviveTrinkets do
        if player:HasTrinket(reviveItems[i]) then
            hasRevive = true
        end
    end
    if (player:GetCard(0) == Card.CARD_SOUL_LAZARUS or player:GetCard(1) == Card.CARD_SOUL_LAZARUS) then
        hasRevive = true
    end

    return hasRevive
end

function champ_util:getAllChampChars(character)
    local championChars = {}
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        
        if player:GetPlayerType() == character and player:HasCollectible(CHAMPION_CROWN) then
            table.insert(championChars, player)
        end
    end
    return championChars
end

function champ_util:anyPlayerHasNullEffect(effect)
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        
        local tempEffects = player:GetEffects()
        if tempEffects:HasNullEffect(effect) then
            return true
        end
    end
    return false
end

return champ_util