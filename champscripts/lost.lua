local lost = {}
local CHAMPION_CROWN = Isaac.GetItemIdByName("Champion Crown")
local CHARACTER = PlayerType.PLAYER_THELOST

function lost:onCache(player, cacheFlag)
    if player == nil then return end
    if cacheFlag ~= CacheFlag.CACHE_LUCK then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end

    local save = IsaacChampions.SaveManager.GetRunSave(player)
    if save then
        if save.ItemObtained == true then return end
        save.ItemObtained = true
    end

    player:RemoveCollectible(CollectibleType.COLLECTIBLE_ETERNAL_D6)
    
    player:AddCollectible(CollectibleType.COLLECTIBLE_RUNE_BAG)
    player:AddCollectible(CollectibleType.COLLECTIBLE_HEARTBREAK)
    player:AddCollectible(CollectibleType.COLLECTIBLE_CLEAR_RUNE, 4, false)
    player:AddCard(Card.RUNE_ALGIZ)

    player:AddBrokenHearts(-2)

    local tempEffects = player:GetEffects()
    if tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
        tempEffects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, 1)
    end
end
IsaacChampions:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, lost.onCache)


function lost:onPerfectUpdate(player)
    if player == nil then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true) then return end
    if player:GetPlayerType() ~= CHARACTER then return end
    if player:HasTrinket(TrinketType.TRINKET_WOODEN_CROSS) then
        if Game():GetRoom():GetFrameCount() ~= 1 then return end
    else
        if Game():GetRoom():GetFrameCount() ~= 0 then return end
    end
    local tempEffects = player:GetEffects()
    if tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
        tempEffects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, 1)
    end
end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, lost.onPerfectUpdate)

-- function lost:onNewFloor()
--     local champions = IsaacChampions:getAllChampChars(CHARACTER)
--     if (next(champions) == nil) then return end
--     for i = 1, #champions do
--         local player = champions[i]
--         local tempEffects = player:GetEffects()
--         if tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
--             tempEffects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, 1)
--         end
--     end
-- end

-- IsaacChampions:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, lost.onNewFloor)

lost.BrokenHeartIcon = Sprite()
lost.BrokenHeartIcon:Load("gfx/custom_ui/ui_hearts.anm2", true)
lost.BrokenHeartIcon:SetFrame("BrokenHeart", 1)
lost.BrokenHeartIcon:LoadGraphics()

lost.BrokenHeartText = Font()
lost.BrokenHeartText:Load("font/pftempestasevencondensed.fnt")

---main.lua
---RENDER--
function IsaacChampions:PostRender()
    local player = Isaac.GetPlayer(0)
    if player == nil then return end
    if not player:HasCollectible(CHAMPION_CROWN) then return end
    if player:GetPlayerType() ~= CHARACTER then return end
    local level = Game():GetLevel()

    if level:GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN > 0 then return end
    if player:HasCurseMistEffect() then return end

    local verticalOffset = 0
    local horizontalOffest = 0
 
    local tempEffects = player:GetEffects()
    if tempEffects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) or IsaacChampions.Utility:hasRevive(player) then 
        if not (IsaacChampions.Utility:hasRevive(player)) then
            horizontalOffest = 13
        else
            verticalOffset = 12
        end
    end
    local iconPos = Vector(IsaacChampions.Utility:HUDOffset(48 + horizontalOffest, 10 + verticalOffset, 'topleft')) -- 47. 13
    local textPos = Vector(IsaacChampions.Utility:HUDOffset(56 + horizontalOffest, 2 + verticalOffset, 'topleft'))  -- 55, 5
    lost.BrokenHeartIcon:Render(iconPos)
    lost.BrokenHeartText:DrawString("x" .. player:GetBrokenHearts(), textPos.X, textPos.Y, KColor(1 ,1 ,1 ,1), 0, true)
end
IsaacChampions:AddCallback(ModCallbacks.MC_POST_RENDER, IsaacChampions.PostRender)

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
        "#{{Player".. CHARACTER .."}} {{ColorGray}}The Lost" ..
        "#{{Collectible" .. CollectibleType.COLLECTIBLE_HOLY_MANTLE .. "}} Disables Holy Mantle effectt" ..
        "#{{Minus}} Removes Collectibles:" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_ETERNAL_D6 .. "}} {{ColorSilver}}Eternal D6" ..
        "#{{Plus}} Adds Collectibles: " ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_HEARTBREAK .. "}} {{ColorSilver}}Heartbreak" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_CLEAR_RUNE .. "}} {{ColorSilver}}Clear Rune" ..
        "#{{Blank}} {{Collectible" .. CollectibleType.COLLECTIBLE_RUNE_BAG .. "}} {{ColorSilver}}Rune Bag" ..
        "#{{Rune}} Gives an algiz rune" ..
        "#{{BrokenHeart}} You die at 12 broken hearts"
        return descObj
    end
    
    EID:addDescriptionModifier("CrownLost", crownPlayerCondition, crownPlayerCallback)
end
