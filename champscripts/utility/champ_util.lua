local champ_util = {}

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

return champ_util